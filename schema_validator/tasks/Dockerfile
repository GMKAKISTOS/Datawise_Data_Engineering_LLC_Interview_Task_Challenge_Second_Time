FROM python:3.11-slim

RUN useradd -m -s /bin/bash model \
&& mkdir -p /workdir \
&& chown model:model /workdir

WORKDIR /workdir

COPY ./tests/ /tests/
COPY ./grader.py /tests/
COPY ./solution.sh /tests/
COPY ./data /workdir/data

RUN chown -R model:model /workdir/data \
&& chmod -R 700 /workdir/data

#docker run --rm -v "C:\Users\panos\schema_validator\tasks\data:/output" apex_arena_task bash -c "bash /tests/solution.sh && cp /workdir/validation_results.json /output/"