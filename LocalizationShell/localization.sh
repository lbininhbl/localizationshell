#!/bin/bash
#set -x

# 记录所花费的时间
start_time=$(date +%s)
totalCost=""

################################## 定义常量或变量 #################################
# =============================== 路径相关 =============================== #
# 当前目录路径
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)
PROJECT_DIR=$(cd "${CURRENT_DIR}/.."; pwd)

cd "$CURRENT_DIR"

# =============================== 文件相关 =============================== #
CSV_FILE="tmp.csv"

################################## 配置相关 #################################
# 多语言表格
xlsx[0]=$(find . -regex '^[^~]*.xlsx$' -iname "*default*")
xlsx[1]=$(find . -regex '^[^~]*.xlsx$' -iname "*sub*")

# 多语言文件名称
LOCALIZABLE_FILES[0]="Localizable.strings"
LOCALIZABLE_FILES[1]="StyleProject.strings"

# 多语言存放的目录名字
LOCALIZABLE_DIR_NAME="Localization"

# 自定义的换行符
NEWLINE="#@@#"

# Localization目录
LOCALIZATION_PATH=$(cd "${PROJECT_DIR}"; cd "$(find . -name "${LOCALIZABLE_DIR_NAME}" -type d)"; pwd)

################################## 自定义函数 #################################
# 格式化时间字符串
function formatCostTime() {
    totalSecond=$1
    
    if [[ $totalSecond -lt 1 ]]; then
        # 毫秒
        totalSecond="${totalSecond}ms"
        echo "进来毫秒了"
    elif [[ $totalSecond -lt 60 ]]; then
        # 秒
        totalCost="${totalSecond}s"
    elif [[ $totalSecond -lt 3600 ]]; then
        # 分
        minut=`expr $totalSecond / 60`
        second=`expr $totalSecond % 60`
        totalCost="${minut}m${second}s"
    else
        # 时
        hour=`expr $totalSecond / 3600`
        minut=`expr $totalSecond % 3600 / 60`
        second=`expr $totalSecond % 3600 % 60`
        totalCost="${hour}h${minut}m${second}s"
    fi
}

################################## 开始执行内容 ##################################

for ((i=0; i<${#xlsx[@]}; i++))
do

current_xlsx=${xlsx[$i]}
current_localizable_file=${LOCALIZABLE_FILES[$i]}

if [ -z "$current_xlsx" ]; then
continue
else
echo "当前的xlsx文件${current_xlsx}"
fi

# 先将xlsx转换成csv，确保安装了python的插件，https://github.com/dilshod/xlsx2csv
xlsx2csv -d 'tab' "$current_xlsx" "$CSV_FILE"

csv_content=`cat $CSV_FILE`

# 获取当前所有列数、行数
allColumn=`echo "$csv_content" | awk -F'\t' 'END{print NF}'`
allRow=`echo "$csv_content" | awk -F't' 'END{print NR}'`

echo -e "总共有${allColumn}列，${allRow}行\n"

# 从第3列开始循环，将每一列多语言写入对应语言的文件中
for ((j=3; j<=$allColumn; j++))
do

# 第一行都是各国的语言代码
language_code=`echo "$csv_content" | awk -F'\t' -v awk_var="$j" '{ if (NR==1) {print $awk_var;}}'`
echo "当前处理的语言: $language_code"

file="${LOCALIZATION_PATH}/${language_code}.lproj/$current_localizable_file"

# 判断是否存在多语言文件
if [ -f "$file" ]; then

    # 1. 读取转换的csv文件的内容
    # 2. awk命令将内容按'tab'为分隔符，将内容分隔
    # 3. 如果是第一行，则添加注释，否则，按"xxx"="xxx";的格式化输出到content中, 如果是空列，则将第二列内容作为模块分类进行注释。
    content=`echo "$csv_content" | awk -F'\t' -v awk_var="$j" '{ if (NR==1) {printf "// %s;\n", $awk_var;} else { keys[NR]=$1; desc[NR]=$2; if ($awk_var == "") { printf "// %s\n", desc[NR]; } else { printf "\"%s\"=\"%s\";\n", keys[NR], $awk_var } } }'`

    # 替换
    content=$(echo "$content" | sed "s/${NEWLINE}/\\\n/g")

    echo "$content" > $file
else
    echo "❗项目没有设置${language_code}的${current_localizable_file}多语言文件"
fi

done

# 最后删除csv文件
rm -f $CSV_FILE

done

# 计算整体执行时长
end_time=$(date +%s)
SECONDS=`expr $end_time - $start_time`
formatCostTime $SECONDS
echo "总用时: ${totalCost}"

echo "完成操作!"

