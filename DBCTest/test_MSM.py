import subprocess
import re
import random

for CURVE in ["NID_secp128r1", "NID_secp256k1", "NID_secp384r1", "NID_secp521r1"]:
    for i in range(1,2):
        TEST_TIMES=131072
        TEST_CASE="MSMTest"
        DBC_COEF=i
        N=0
        
        if CURVE=="NID_secp128r1":
            INTS=5
            N=128
        if CURVE=="NID_secp256k1":
            INTS=9
            N=256
        if CURVE=="NID_secp384r1":
            INTS=13
            N=384
        if CURVE=="NID_secp521r1":
            INTS=17
            N=521
            
        print("INTS=",INTS)
        print("DBC_COEF=", DBC_COEF)
        print("TEST_CASE=",TEST_CASE)
        # Step 1: Compile the C++ code
        cpp_code = f"variables.cpp optimal_DBC.cpp subOptimal_DBC.cpp EOS_DBC.cpp {TEST_CASE}.cpp"
        executable = TEST_CASE
        compile_command = f"g++ -DCURVE={CURVE} -DTEST_TIMES={TEST_TIMES} -DDBC_COEF={DBC_COEF} -o {executable} {cpp_code} -I ./openssl/include -L ./openssl/lib64 -Wl,-rpath=./openssl/lib64 -lcrypto -O3"

        try:
            compile_result = subprocess.run(compile_command, shell=True, check=True, text=True, capture_output=True)
            if compile_result.returncode != 0:
                print(f"Compilation failed:\n{compile_result.stderr}")
                exit(1)
            print("Compilation successful.")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred during compilation: {e}")
            exit(1)

        # 构建测试样例
        input_num=list()
        input_data=str()
        for r in range(TEST_TIMES):
            input_num.append(random.randint(0,2**N-1))
            # print(input_num)
            input_data += str(hex(input_num[r]))[2:]+'\n'
        run_command = f"./{executable}"

        try:
            run_result = subprocess.run(run_command, shell=True, check=True, text=True, capture_output=True, input=input_data)
            if run_result.returncode != 0:
                print(f"Execution failed:\n{run_result.stderr}")
                exit(1)
            
            output = run_result.stdout.split('\n')
            print(run_result.stdout)
            

        except subprocess.CalledProcessError as e:
            print(f"An error occurred during execution: {e}")
            print(hex(input_num[r]))
            
            exit(1)
        except:
            print("Error")
            print("INTS=",INTS)
            print("r=",r)
            print("input_num=",hex(input_num[r]))
            print("output=",output[r])
            exit(1)
    
    