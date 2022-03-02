# haproxy22

docker build -f Dockerfile -t vanessamello/haproxy:2.2 .


docker run -itd --privileged --rm -p 443:443 -p 80:80 --name haproxy22 vanessamello/haproxy:2.2

haproxy -c -V -f /etc/haproxy/haproxy.cfg

