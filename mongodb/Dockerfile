FROM mongo:3.6

RUN apt-get update && apt-get install -y \
  python \
  curl \
  cron \
  rsyslog

RUN curl -sL https://bootstrap.pypa.io/get-pip.py | python && \
  pip install awscli

ADD *.sh /root/
ADD ./crontab /etc/cron.d/backup
RUN chmod 0644 /etc/cron.d/backup
RUN touch /var/log/cron.log

CMD rsyslogd && \
  cron && \
  env | sed 's/^\(.*\)\=\(.*\)$/\1\="\2"/g' | grep -E "^(AWS|ENV)" | cat - /etc/cron.d/backup > /root/backup.cron && \
  mv /root/backup.cron /etc/cron.d/backup && \
  mongod --bind_ip 0.0.0.0 && \
  tail -f /var/log/syslog

