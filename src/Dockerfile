FROM python:3-slim

COPY . .

COPY app.py .

COPY requirement.txt .

RUN pip3 install -r requirement.txt

EXPOSE 8080

ENV FLASK_APP=app

CMD ["python3", "-m" , "flask" , "run" , "--host=0.0.0.0" , "--port=8080" ]
