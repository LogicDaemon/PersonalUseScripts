''' Decorator for caching function results for a given time to live (ttl)
'''

from functools import wraps
import time
from typing import (Callable, Dict, Generic, TypeVar)
from typing_extensions import ParamSpec  # requires ≥3.10

from .shared_func import ReprFromAnnotationsMixin

_PARAM_SPEC = ParamSpec('_PARAM_SPEC')
_RETURN_TYPE = TypeVar('_RETURN_TYPE')


class TTLCacheCachedResult(Generic[_RETURN_TYPE], ReprFromAnnotationsMixin):
    value: _RETURN_TYPE
    expires: float
    __slots__ = tuple(__annotations__)

    def __init__(self, value: _RETURN_TYPE, expires: float) -> None:
        self.value = value
        self.expires = expires


def ttl_cache(
    ttl_s: float
) -> Callable[[Callable[_PARAM_SPEC, _RETURN_TYPE]], Callable[_PARAM_SPEC,
                                                              _RETURN_TYPE]]:
    ''' Returns a wrapper which will cache function results for tts_s sec '''

    def decorator(
        func: Callable[_PARAM_SPEC, _RETURN_TYPE]
    ) -> Callable[_PARAM_SPEC, _RETURN_TYPE]:
        cache: Dict[tuple, TTLCacheCachedResult[_RETURN_TYPE]] = {}

        @wraps(func)
        def wrapper(*args: _PARAM_SPEC.args,
                    **kwargs: _PARAM_SPEC.kwargs) -> _RETURN_TYPE:
            key = (args, tuple(kwargs.items()))
            try:
                cached = cache[key]
                if cached.expires > time.monotonic():
                    return cached.value
                del cache[key]
            except KeyError:
                pass
            for k in list(cache):
                if cache[k].expires < time.monotonic():
                    del cache[k]
            cache[key] = cached = TTLCacheCachedResult(
                func(*args, **kwargs),
                time.monotonic() + ttl_s)
            return cached.value

        return wrapper

    return decorator
