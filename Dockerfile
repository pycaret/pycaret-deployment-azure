FROM python:3.7

RUN pip install virtualenv
ENV VIRTUAL_ENV=/venv
RUN virtualenv venv -p python3
ENV PATH="VIRTUAL_ENV/bin:$PATH"

WORKDIR /app
ADD . /app

# Install dependencies
RUN pip install -r requirements.txt

# Resolve issue "ImportError: cannot import name 'soft_unicode' from 'markupsafe'"
# https://github.com/aws/aws-sam-cli/issues/3661#issuecomment-1049916359
RUN pip uninstall -y markupsafe
RUN pip install markupsafe==2.0.1

# Expose port 
EXPOSE 5000

# Run the application:
CMD ["python", "app.py"]
