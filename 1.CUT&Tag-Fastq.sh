1、环境激活
Conda activate bw2
# --- 环境配置区 ---
# 设置要使用的线程数 (64核服务器，用60个)
export THREADS=60

# 设置参考基因组文件名
export GENOME_FA="Homo_sapiens.GRCh38.dna.toplevel.fa"

# 设置Bowtie2索引的前缀名
export GENOME_INDEX="GRCh38_index"
# --- 配置结束 ---

# 创建所有需要的输出目录
mkdir -p 01_fastqc_raw
mkdir -p 02_trimmed_reads
mkdir -p 03_alignment_bam
mkdir -p logs

echo "环境变量设置完毕，输出目录已创建。"




echo "开始使用 Trim Galore! 清洗数据..."

# 循环处理 ctrl 和 NFIA 两个样本
for sample in "ctrl" "NFIA"
do
    echo "--> 正在清洗样本: $sample"
    # --cores 8 对trimming来说足够了，可以避免过多小文件读写的瓶颈
    # --fastqc 参数会自动对清洗后的数据再跑一次质控
    trim_galore --paired --fastqc --cores 8 -o 02_trimmed_reads/ ${sample}_1.fq.gz ${sample}_2.fq.gz > logs/${sample}_trimming.log 2>&1
done

echo "所有样本数据清洗完成。"
echo "清洗后的文件位于 '02_trimmed_reads/' 目录。"
echo "Trim Galore! 自动生成的质控报告也在此目录中。"