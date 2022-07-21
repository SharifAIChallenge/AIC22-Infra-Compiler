from event import Event_Status
from compiler import compile
import kafka_cli as kcli
import json
import log
import logging

print("beginning main.py")


log.init()
logger = logging.getLogger("main")
logger.info("compiler module is up and healty")

for message in kcli.get_consumer():
    token=""
    try:
        code = json.loads(message.value.decode("utf-8"))
        token=code['code_id']
        log.new_token_logger(code['code_id'])

        logger.info(f"{'='*31}[{code['code_id']}]{'='*31}")
        logger.info("successfully accuried new record")
        
        event = compile(code['code_id'], code['language'])
        
        logger.info(f"event retrived with status code [{Event_Status(event.status_code).name}]")
        logger.info(f"resulting event is: {event.title}")
        
        kcli.push_event(event.__dict__)
    except Exception as e:
        logger.exception(f"exception accured:{e}")
    finally:
        kcli.get_consumer().commit()
        logger.info('='*32*3)
        log.remove_token_logger(token)
    
print("done main.py")
