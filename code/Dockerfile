FROM perl:5.36.0

RUN cpanm Path::Tiny@0.144
RUN cpanm JSON::Validator@5.13

COPY . /app/

WORKDIR /app/

CMD perl -I/app/lib/ /app/bin/app.pl
