#1、环境切换（trimmomatic不在bw2环境中）
Conda activate trimmomatic
#环境配置区#
export THREADS=60

echo "开始使用 Trimmomatic 清洗数据 (Conda 版本)..."

# --- Trimmomatic 配置 ---
# 接头文件的路径
ADAPTERS_FA="02_trimmed_reads/TruSeq3-PE-2.fa"

# 循环处理 ctrl 和 NFIA 两个样本
for sample in "ctrl" "NFIA"
do
    echo "--> 正在清洗样本: $sample"

    # 直接调用 trimmomatic 命令
    trimmomatic PE -threads $THREADS \
        ${sample}_1.fq.gz \
        ${sample}_2.fq.gz \
        02_trimmed_reads/${sample}_1_paired.fq.gz \
        02_trimmed_reads/${sample}_1_unpaired.fq.gz \
        02_trimmed_reads/${sample}_2_paired.fq.gz \
        02_trimmed_reads/${sample}_2_unpaired.fq.gz \
        ILLUMINACLIP:${ADAPTERS_FA}:2:30:10 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36 > logs/${sample}_trimmomatic.log 2>&1
done

echo "所有样本数据清洗完成。"
echo "清洗后的文件位于 '02_trimmed_reads/' 目录。"