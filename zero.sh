echo "======JAVA======"
echo "1.部署项目"
echo "2.查看所有部署项目"
echo "3.根据PID查端口号"
echo "4.根据PID杀死进程"
echo "5.查看端口占用情况"
echo "================"
echo "请选择指令:"

read order

# 部署java项目
if (($order ==  1)); then
	echo "请输入项目名称:"
	read name
	nohup java -jar ${name}.jar > ${name}.txt 2>&1 &
	echo "是否查看日志(y/n):"
	read flag
	if [ $flag = "y" ] || [ $flag = "Y" ]
	then
		echo "==============================================================="
		while read line
		do
			echo $line
		done < "$name.txt"
		echo "==============================================================="
	fi

# 查看所有部署的java项目
elif (($order ==  2)); then
	ps -ef|grep java

#根据PID查端口
elif (($order ==  3)); then
	echo "请输入PID号:"
	read pid
	netstat -nap|grep $pid

# 根据PID杀死进程
elif (($order ==  4)); then
	echo "请输入PID号:"
	read pid
	kill -9 $pid

# 查看端口占用
elif (($order ==  5)); then
	echo "请输入端口号:"
	read port
	lsof -i:$port

else
	echo "请输入正确指令!!!"
fi
