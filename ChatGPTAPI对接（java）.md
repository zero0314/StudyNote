
## 消息实体定义
```
/**
 * 封装的消息实体
 * @author yh
 */
public class Message {
    /**
     * 角色可选：system、assistant、user
     */
    private String role;
    /**
     * 对话内容
     */
    private String content;

    public Message() {
    }

    public Message(String role, String content) {
        this.role = role;
        this.content = content;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
```

## 基于Apache的httpclient请求

> 模型:gpt-3.5-turbo
```

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;

import java.util.ArrayList;
import java.util.Scanner;
import java.util.logging.Logger;

/**
 * @author yh
 */
public class ChatGPT {
    public static void main(String[] args) throws Exception {
        //从控制台输入问题
        Scanner scanner = new Scanner(System.in);
        String question = scanner.nextLine();
        //存放历史对话
        ArrayList<Message> arrayList = new ArrayList<>();
        //连续对话，直到输入quit
        while (!"quit".equals(question)) {
            //Apache的httpclient
            HttpClient httpClient = HttpClientBuilder.create().build();
            //接口
            HttpPost request = new HttpPost("https://api.openai.com/v1/chat/completions");
            //请求类型
            request.addHeader("Content-Type", "application/json");
            //ChatGPT的key
            request.addHeader("Authorization", "Bearer sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
            //用fastJSON2来构造请求体
            JSONObject requestBody = new JSONObject();
            //模型指定
            requestBody.put("model", "gpt-3.5-turbo");
            //提问的消息实体（Message对象）
            arrayList.add(new Message("user", question));
            requestBody.put("messages", JSON.toJSON(arrayList));
            //将请求头添加到请求中
            StringEntity requestEntity = new StringEntity(requestBody.toString());
            request.setEntity(requestEntity);
            //发送请求
            HttpResponse response = httpClient.execute(request);
            //获取返回体
            String responseString = EntityUtils.toString(response.getEntity());
            //日志
            Logger.getGlobal().info(responseString);
            //以下都是对返回体进行解析的过程
            JSONObject jsonObject = JSON.parseObject(responseString);
            String choices = jsonObject.getJSONArray("choices").get(0).toString();
            JSONObject parseObject = JSON.parseObject(choices).getJSONObject("message");
            Message answer = new Message(parseObject.getString("role"), parseObject.getString("content").replace("\n", ""));
            //控制台输出
            System.out.println("Role: user");
            System.out.println("Content: " + question);
            System.out.println("Role: " + answer.getRole());
            System.out.println("Content: " + answer.getContent());
            //将本次对话存到历史记录中，以实现连续对话
            arrayList.add(answer);
            //继续对话
            question = scanner.nextLine();
        }
    }
}


```
