import logging

from consts import LOG_LEVEL


def get_logger(module_name: str) -> logging.Logger:
    logger = logging.getLogger(module_name)
    logger.setLevel(LOG_LEVEL)
    formatter = logging.Formatter(
        "[%(asctime)s] | [%(name)s] | [%(levelname)s]: %(message)s"
    )
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    return logger
