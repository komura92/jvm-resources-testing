JVM_IMAGE_NAME="eclipse-temurin:21-jre-alpine"

declare -a MEMORY_SIZES_TO_TEST=("512m" "1G" "2G" "4G")
declare -a CPUs_NUMBERS_TO_TEST=("1" "2" "4" "6")

for memory_size in "${MEMORY_SIZES_TO_TEST[@]}"
do
	for cpus_number in "${CPUs_NUMBERS_TO_TEST[@]}"
  do
    echo "######################################################################################################"
    echo "TESTING CASE:"
    echo "  RAM: $memory_size"
    echo "  CPUs: $cpus_number"
    docker run --rm --memory "$memory_size" --cpus "$cpus_number" \
      -v .:/test_code \
      "$JVM_IMAGE_NAME" \
      sh -c "cd /test_code && java Main"
    echo "######################################################################################################"
  done
done
