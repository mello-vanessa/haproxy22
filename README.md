# haproxy22

docker network create haproxy-net

docker build -f Dockerfile -t vanessamello/haproxy:2.2 .

docker run -itd --network haproxy-net--privileged --rm -p 443:443 -p 80:80 --name haproxy22 vanessamello/haproxy:2.2

docker run -itd --network haproxy-net --privileged --rm -p 443:443 --name haproxy22-kong 006563289334.dkr.ecr.us-east-1.amazonaws.com/haproxy22:latest


haproxy -c -V -f /etc/haproxy/haproxy.cfg

