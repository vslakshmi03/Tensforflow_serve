 clone https://github.com/tensorflow/serving.git

cd serving

Create tensorflow-serve.py

Run python script, python tensorflow-serve.py.

docker pull tensorflow/serving , docker run -p 8501:8501 -v /home/tfserving/universal_encoder:/models/universal_encoder -e MODEL_NAME=universal_encoder -t tensorflow/serving &

curl -d '{ "inputs": {"text": ["what this is"]} }' -X POST http://localhost:8501/v1/models/universal_encoder:predict

http://host:8501/v1/models/universal_encoder in browser

apt-get update; apt-get install curl (install curl in docker container and use step 6 command)

                                 USE CASE
Create tensorflow-serve container as host in each Instance where we need the model.

For other containers which requires the model- In task definition will change Network Mode - Host.
