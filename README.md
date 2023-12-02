# test-ingress
built to test ingress control in kubernetes

## commands
docker build -t test_ingress .
docker run -d -p 8080:80 test_ingress
curl http://localhost:8080/