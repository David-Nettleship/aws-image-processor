FROM python:3.8-slim

WORKDIR /app
COPY requirements.txt .
COPY resizer.py .

RUN pip install --no-cache-dir -r requirements.txt

# Create directories for input and output images
RUN mkdir -p /app/input /app/output

EXPOSE 80

CMD ["python", "resizer.py"]
