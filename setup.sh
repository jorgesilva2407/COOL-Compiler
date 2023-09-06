docker build -t cool .
docker create --name cool -it -v $(pwd):/home/workspace cool