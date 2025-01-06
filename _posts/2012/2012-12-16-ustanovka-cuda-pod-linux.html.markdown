---
title: "Установка CUDA под Linux"
author:
  display_name: "Герман"
  email: dxdy@bk.ru
tags:
  - Новости
  - CUDA
  - Linux
---

Давайте рассмотрим пример по установке CUDA под Linux. Для примера возьмем сырой дистрибутив OpenSuse (только что установленный на жесткий диск) и проделаем все операции по установке, настройке и сборке первого проекта на CUDA.


Для начала следует обновить дистрибутив OpenSuse до самых свежих и стабильных пакетов на текущей момент. Совет очень важный, так как порой при установке драйвера nvidia требуется пакет kernel-devel. Несовпадение пакета необходимый для драйвера nvidia с пакетом который установлен у вас в системе может повлечь к сбою в установке драйвера.

По умолчанию в дистрибутиве OpenSuse стоит бесплатный видеодрайвер nouveau, который необходимо занести в черный список:

```bash
  sudo echo -e "blacklist nouveau\\noptions nouveau modeset=0" >> /etc/modprobe.d/50-blacklist.conf
```

Теперь нам необходимо узнать какая у нас видеокарта:

```bash /sbin/lspci | grep -i vga```

В итоге вы должны получить похожую строчку:

```bash
  01:00.0 VGA compatible controller: nVidia Corporation GT216 [GeForce GT 240M] (rev a2)
```

<!-- excerpt-end -->

Как видите я являюсь обладателем недорогой видеокарты GeForce GT240M. Теперь заходим на сайт [nvidia](http://www.nvidia.ru/Download/index.aspx?lang=ru) и скачиваем драйвер под свою видеокарту.

В итоге мы получим файл NVIDIA-Linux-**-**.**.run. Перед установкой нам необходимо установить необходимые пакеты (компилятор и пакет разработчика для ядра):

```cpp
zypper in kernel-devel gcc
```

Теперь нам необходимо остановить иксы:

```cpp
sudo /etc/init.d/xdm stop
```

И начать установку драйвера:

```cpp
sudo chmod +x NVIDIA-Linux-**-**.**.run
sudo ./NVIDIA-Linux-**-**.**.run
```

Теперь можно перезагрузить систему и проверить, что драйвер установлен:

```cpp
cat /etc/X11/xorg.conf | grep "Driver"
```

Осталось установить CUDA. Для начала с сайта [nvidia](https://developer.nvidia.com/cuda-toolkit-archive) скачиваем файл CUDA Toolkit, который содержит все необходимое для написания и запуска программ на CUDA. Вместе с CUDA Toolkit скачивают файл GPU Computing SDK code samples, который содержит кучу примеров для изучения технологии CUDA.

Установку CUDA начнем с файла CUDA Toolkit:

```cpp
sudo chmod +x cudatoolkit_**.run
sudo ./cudatoolkit_**.run
```

Программа предложит вам путь куда установить ПО для CUDA. Лучше оставить путь по умолчанию: `cpp /usr/local/`.

Аналогично проделываем операцию по установке GPU Computing SDK code samples. Теперь можно написать первую программу... но наш компьютер не видит компилятор nvcc, поэтому добавим пути в переменное окружение (добавить строки в файл ~/.profile):

```cpp
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib:$LD_LIBRARY_PATH
```

Внимание! Если у вас 64 разрядная система, то указываем путь до папки lib64

```cpp
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

Теперь можно написать первую программу, которую пишут на всех языках:

```cpp
#include <stdio.h>
#include <stdlib.h>

__global__ void HelloCUDA(char* result, int num){

  int i = 0;
  char p_HelloCUDA[] = "Hello CUDA!";
  for(i = 0; i < num; i++) {
    result[i] = p_HelloCUDA[i];
  }
}

int main(int argc, char* argv[]){

  char  *device_result  = 0;
  char  host_result[12] = {0};

  cudaMalloc((void**) &device_result, sizeof(char) * 11);

  HelloCUDA<<<1, 1>>>(device_result, 11);

  cudaThreadSynchronize();

  cudaMemcpy(host_result, device_result, sizeof(char) * 11, cudaMemcpyDeviceToHost);

  cudaFree(device_result);
  printf("%s\n", host_result);

  return 0;
}
```

Для компиляции и запуска программы необходимо:

```cpp
nvcc hello.cu -o hello.o
 ./hello.o
```

Код достаточно грубый, ведь мы не обратываем ошибки при вызове функций CUDA. Для этого лучше посмотреть примеры из CUDA SDK, где через макросы обрабатываются исключения. Но для этого необходимо указывать компилятору путь до заголовочного файла cutil_inline.h из CUDA SDK.

Для обучения добавлю еще пару примеров:

**Сложение векторов**:

```cpp
#include <stdio.h>
#include <cuda_runtime_api.h>

__global__ void sum(float* A, float* B, float* C, int N){

    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N)
        C[i] = A[i] + B[i];
}

void init(float *arr, int size, float value){

  for(int i = 0; i < size; ++i)
    arr[i] = value;
}

int main(){

  int N = 500000;
  size_t size = N * sizeof(float);

  float *A, *B, *C;
  A = (float *)malloc(size);
  B = (float *)malloc(size);
  C = (float *)malloc(size);

  init(A, N, 1); init(B, N, 0);

  float *cudaA, *cudaB, *cudaC;
  cudaMalloc((void **) &cudaA, size);
  cudaMalloc((void **) &cudaB, size);
  cudaMalloc((void **) &cudaC, size);

  cudaMemcpy(cudaA, A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(cudaB, B, size, cudaMemcpyHostToDevice);

  dim3 threads = dim3(256, 1);
  dim3 blocks = dim3((N + threads.x) / threads.x, 1);

  sum<<< blocks, threads >>> (cudaA, cudaB, cudaC, N);

  cudaMemcpy(C, cudaC, size, cudaMemcpyDeviceToHost);

  float sum = 0;
  for(int i = 0; i < N; ++i)
    sum += C[i];

  printf("Summa %f\n", sum);

  free(A); free(B); free(C);
  cudaFree(cudaA); cudaFree(cudaB); cudaFree(cudaC);

  return 0;
}

```

**Транспонирование матрицы**:

```cpp
#include <stdio.h>
#include <cuda_runtime_api.h>

__global__ void trans(int* A, int* B, int N){

  int xIndex = blockDim.x * blockIdx.x + threadIdx.x;
  int yIndex = blockDim.y * blockIdx.y + threadIdx.y;

  int inIndex = xIndex + N * yIndex;
  int outIndex = yIndex + N * xIndex;

  B[inIndex] = A[outIndex];
}

void init(int *arr, int size){

  for(int i = 0; i < size; ++i)
    for(int j = 0; j < size; ++j)
      arr[i*size+j] = i;
}

void print(int *arr, int size){

  for(int i = 0; i < size; ++i){
    for(int j = 0; j < size; ++j)
      printf("%d ", arr[i*size+j]);
    printf("\n");
  }

  printf("\n");
}

int main(){

  int N = 16;
  int block = 16;

  size_t size = N*N * sizeof(int);

  int *A, *B;
  A = (int *)malloc(size);
  B = (int *)malloc(size);

  init(A, N);
  print(A, N);

  int *cudaA, *cudaB;
  cudaMalloc((void **) &cudaA, size);
  cudaMalloc((void **) &cudaB, size);

  cudaMemcpy(cudaA, A, size, cudaMemcpyHostToDevice);

  dim3 threads = dim3(block, block);
  dim3 blocks = dim3(N / threads.x, N / threads.y);

  trans<<< blocks, threads >>> (cudaA, cudaB, N);

  cudaMemcpy(B, cudaB, size, cudaMemcpyDeviceToHost);

  print(B,N);

  free(A); free(B);
  cudaFree(cudaA); cudaFree(cudaB);

  return 0;
}
```
