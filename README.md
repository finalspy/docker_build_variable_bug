# docker_build_variable_bug
A simple way to reproduce 2 different behavior regarding variables in Dockerfile or in image depending if you use buildkit or not to construct the image.
Not sure yet if this is the intended behavior and so if the problem come from buildkit or from the Dockerfile I use.

## the strange beahvior 

### prerequisite
You have in your image an environment variable already set with a value.
In your Dockerfile you define the same name for an ARG with a default value.

### First thing
**Without buildkit** the logs show the ARG/environement **variable name**.
**With buildkit** logs shows the **variable's value** of the ARG/environment variable, not the name.

### Second one
If in a RUN you use this variable let's say in a if statement, then the reslt will be different depending on if you use buildkit or not.
I noticed that while building : [https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile] using --build-arg BASE_CONTAINER="python:3.6-slim-stretch" (to replace the ubuntu default image). Without buildkit it ran with no problems, but with buildkit this ended in Conda running for several hours trying to solve dependency issues. Then I noticed some logs refering to Python3.7 besides I used a base image of Python 3.6. 
After several hours digging into this I determined that the problem came from : [https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile#L86]
And then I setup this short project to demonstrate the behavior that caused the conda issue.


## Steps to reproduce
Launch './build_nobk.sh' it should build an image **without** buildkit and run it using the file Dockerfile_bugarg.
Here's a sample output :

  Sending build context to Docker daemon  53.25kB
  Step 1/7 : FROM python:3.6-slim-stretch
    ---> 8f4617e3e809
  Step 2/7 : RUN echo $PYTHON_VERSION
    ---> Running in 3efd75bb32c1
    3.6.10
  Removing intermediate container 3efd75bb32c1
    ---> 8973f029e7ea
  Step 3/7 : RUN echo "vrai" > result1.txt; if [ ! **$PYTHON_VERSION** = 'default' ]; then echo "faux" > result1.txt ; fi
    ---> Running in 8046878ad881
  Removing intermediate container 8046878ad881
    ---> c40072a39157
  Step 4/7 : ARG PYTHON_VERSION=default
    ---> Running in b71d0f3b3325
  Removing intermediate container b71d0f3b3325
    ---> fe2819af10f9
  Step 5/7 : RUN echo $PYTHON_VERSION
    ---> Running in 418b243946f1
    3.6.10
  Removing intermediate container 418b243946f1
    ---> 6463646b8adf
  Step 6/7 : RUN echo "vrai" > result2.txt; if [ ! **$PYTHON_VERSION** = 'default' ]; then echo "faux" > result2.txt ; fi
    ---> Running in 6726a0303aed
  Removing intermediate container 6726a0303aed
    ---> 899cecd716da
  Step 7/7 : CMD [ "sh", "-c", "echo $PYTHON_VERSION && cat result1.txt && cat result2.txt" ]
    ---> Running in 5741b505c4dd
  Removing intermediate container 5741b505c4dd
    ---> c84d17ce2354
  Successfully built c84d17ce2354
  Successfully tagged bug:nobk

  3.6.10
  faux
  *faux*


Launch './build_bk.sh' it should build an image **with** buildkit and run it using the file Dockerfile_bugarg.
Here's a sample output :

  [+] Building 2.0s (9/9) FINISHED                                  
  => [internal] load .dockerignore                            0.0s
  => => transferring context: 2B                              0.0s
  => [internal] load build definition from Dockerfile_bugvar  0.0s
  => => transferring dockerfile: 454B                         0.0s
  => [internal] load metadata for docker.io/library/python:3  0.0s
  => CACHED [1/5] FROM docker.io/library/python:3.6-slim-str  0.0s
  => [2/5] RUN echo 3.6.10                                    0.4s
  => [3/5] RUN echo "vrai" > result1.txt; if [ ! **3.6.10** = 'd  0.6s
  => [4/5] RUN echo default                                   0.5s
  => [5/5] RUN echo "vrai" > result2.txt; if [ ! **default** = '  0.5s
  => exporting to image                                       0.0s
  => => exporting layers                                      0.0s
  => => writing image sha256:0f2e4177f6b7637b9e9f0196e08f7dc  0.0s
  => => naming to docker.io/library/bug:bk                    0.0s

  3.6.10
  faux
  **vrai**

## Conclusion
Need to determine if this behavior is intended or not, and anyway be carefull choosing names for ARG in Dockerfile.
