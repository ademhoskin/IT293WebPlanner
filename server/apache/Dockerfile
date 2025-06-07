FROM base AS apache
COPY server/apache/000-default.conf /etc/httpd/conf.d/000-default.conf
EXPOSE 80
CMD ["/usr/sbin/httpd", "-DFOREGROUND"] 