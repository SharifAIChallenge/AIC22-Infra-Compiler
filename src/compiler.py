from minio_cli import MinioClient, BucketName
import subprocess
from event import Event, Event_Status
import logging

logger=logging.getLogger("compiler")

def download_code(code_id, dest) -> bool:
    zip_file = MinioClient.get_file(code_id, BucketName.Code.value)
    if zip_file is None:
        return False

    with open(dest, 'wb') as f:
        f.write(zip_file)

    return True


def __compile(src, language, dest) -> int:
    logger.info("starting the compiling process")
    cmd = subprocess.Popen(["./compiler-psudo.sh", src, language, dest],
                           stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    # logger.debug(cmd.stdout.read())
    # logger.debug(cmd.stderr.read())
    cmd.communicate()
    
    logger.debug(f"compiling process finished with returncode: {cmd.returncode}")
    return cmd.returncode


def compile(code_id, language) -> Event:
    logger.info(f'1.receive message with code_id: {code_id}, language: {language}')

    source_file = 'code.zip'
    if not download_code(code_id, source_file):
        return Event(token=code_id, status_code=Event_Status.FILE_NOT_FOUND.value,
                     title='failed to fetch the raw code!')

    logger.info(f'2.download code with code_id: {code_id}, language: {language}')

    if __compile(source_file, language, 'bin.tgz') != 0:
        with open('../scripts/compile.log', 'r') as logfile:
            return Event(token=code_id, status_code=Event_Status.COMPILE_FAILED.value,
                         title='failed to compile code!', message_body=logfile.read())
    logger.info(f'3.compile code with code_id: {code_id}, language: {language}')

    with open('bin.tgz', 'rb') as compiled:
        if not MinioClient.upload(code_id, compiled, BucketName.Code.value):
            return Event(token=code_id, status_code=Event_Status.UPLOAD_FAILED.value,
                         title='failed to upload the code!')

    return Event(token=code_id, status_code=Event_Status.COMPILE_SUCCESS.value,
                 title='code successfully compiled!')
