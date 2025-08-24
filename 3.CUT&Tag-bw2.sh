1、#构建索引#
echo "开始建立 Bowtie2 索引..."

# 使用完整路径指定参考基因组文件
bowtie2-build --threads $THREADS /disk192/users_dir/buyu/2.参考基因组/1.human/Homo_sapiens.GRCh38.dna.toplevel.fa GRCh38_index

echo "Bowtie2 索引建立完成。"

2、开始比对、排序、去重复、索引 bowtie2 -> samtools fixmate -> samtools sort -> samtools markdup -> samtools index
echo "开始序列比对与BAM文件处理 (已加入 fixmate 步骤)..."

# 循环处理 ctrl 和 NFIA 两个样本
for sample in "ctrl" "NFIA"
do
    echo "-------------------------------------------------"
    echo "--> 正在处理样本: $sample"
    echo "-------------------------------------------------"

    # --- 定义文件名 ---
    TRIMMED_R1="02_trimmed_reads/${sample}_1_paired.fq.gz"
    TRIMMED_R2="02_trimmed_reads/${sample}_2_paired.fq.gz"
    
    # 我们需要一个新的中间文件名
    FIXMATE_BAM="03_alignment_bam/${sample}.fixmate.bam"
    SORTED_BAM="03_alignment_bam/${sample}.sorted.bam"
    DEDUP_BAM="03_alignment_bam/${sample}.dedup.bam"
    
    # 1. 运行 Bowtie2 比对，并将输出通过管道传给 samtools fixmate
    echo "    -> 步骤 4a: 运行 Bowtie2 和 samtools fixmate..."
    bowtie2 -p $THREADS -x $GENOME_INDEX -1 $TRIMMED_R1 -2 $TRIMMED_R2 | samtools fixmate -@ $THREADS -m - - | samtools sort -@ $THREADS -o $SORTED_BAM
    echo "    -> 已生成修复并排序的BAM文件: ${SORTED_BAM}"

    # 2. 标记 PCR 重复
    echo "    -> 步骤 4b: 运行 samtools markdup 标记PCR重复..."
    samtools markdup -@ $THREADS -s ${SORTED_BAM} ${DEDUP_BAM}
    echo "    -> 去重复后的BAM文件已生成: ${DEDUP_BAM}"

    # 3. 为最终的BAM文件建立索引
    echo "    -> 步骤 4c: 运行 samtools index 为最终BAM文件建立索引..."
    samtools index -@ $THREADS ${DEDUP_BAM}
    echo "    -> BAM 索引建立完成。"
    
    # 4. 清理中间文件
    rm ${SORTED_BAM}
    
done

echo "-------------------------------------------------"
echo "所有样本比对和BAM处理完成！"
echo "最终文件位于 '03_alignment_bam/' 目录，并以 .dedup.bam 结尾。"
