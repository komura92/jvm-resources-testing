# Testing JVM resources availability in docker environment

## Introduction
JVM is changing over the time what makes us, Software Engineers, to periodically measure stability of our applications. JVM flag adaptations can be needed not only when upgrading JDK but also when we are changing available app cloud resources. If we pay for resources, we should use them in the most effective way. This repository provides useful scripts and code to make resource control easier.

## Testing JVM flags
To test default JVM flags values depending on given resources I’m using script docker-jvm-flags.sh (available on GitHub repo). You can easily modify it according to your preferences. Basically it runs JRE docker image with given memory and CPUs resources and for each of them executes command to get default JVM flags and filtering (with grep) those, which we specified on JVM_FLAGS_TO_PRINT list.

#### <u>docker-jvm-flags.sh</u>
    JVM_IMAGE_NAME="eclipse-temurin:21-jre-alpine"

    JVM_FLAGS_TO_PRINT="MaxHeapSize|MaxRAMPercentage|UseG1GC|UseSerialGC"

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
                "$JVM_IMAGE_NAME" \
                sh -c "java -XX:+PrintFlagsFinal -version | grep -E '$JVM_FLAGS_TO_PRINT'"
            echo "######################################################################################################"
        done
    done

Here is sample output of one test case:

    ######################################################################################################
    TESTING CASE:
    RAM: 512m
    CPUs: 1
    size_t MaxHeapSize                              = 134217728                                 {product} {ergonomic}
    openjdk version "21.0.1" 2023-10-17 LTS
    OpenJDK Runtime Environment Temurin-21.0.1+12 (build 21.0.1+12-LTS)
    OpenJDK 64-Bit Server VM Temurin-21.0.1+12 (build 21.0.1+12-LTS, mixed mode, sharing)
    double MaxRAMPercentage                         = 25.000000                                 {product} {default}
    size_t SoftMaxHeapSize                          = 134217728                              {manageable} {ergonomic}
    bool UseG1GC                                  = false                                     {product} {default}
    bool UseSerialGC                              = true                                      {product} {ergonomic}
    ######################################################################################################

## Testing Java app available resources
For testing available resources from inside Java application you can find Main.java class and docker-jdk-available-processors.sh script useful. 

#### <u>Main.java</u>
    public class Main {
        public static void main(String[] args) {
            System.out.println("availableProcessors: " + Runtime.getRuntime().availableProcessors());
            System.out.println("totalMemory:         " + Runtime.getRuntime().totalMemory());
            System.out.println("maxMemory:           " + Runtime.getRuntime().maxMemory());
            System.out.println("freeMemory:          " + Runtime.getRuntime().freeMemory());
        }
    }

#### <u>docker-jdk-available-processors.sh</u>
    JVM_IMAGE_NAME="eclipse-temurin:21-jdk-alpine"

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
                sh -c "java /test_code/Main.java"
            echo "######################################################################################################"
        done
    done


As you probably noticed I used JDK instead of JRE to simplify this test.  If you want to run this application on JRE image you can take a look on docker-build-Main-in-image.sh (it compiles Main.java to bytecode - inside docker image so local JDK not required - which allows us to run it with JRE) and docker-jre-available-processors.sh (slightly modified JDK version to run bytecode with JRE). You can also do it in the classic way - build bytecode file with your own JDK and then test resources with docker-jre-available-processors.sh script.
#### <u>docker-build-Main-in-image.sh</u>
    JVM_IMAGE_NAME="eclipse-temurin:21-jdk-alpine"

    docker run --rm \
        -v .:/test_code \
        "$JVM_IMAGE_NAME" \
        sh -c "cd /test_code && javac Main.java"

#### <u>docker-jre-available-processors.sh</u>
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

