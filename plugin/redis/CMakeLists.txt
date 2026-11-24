nvgt_add_plugin(redis
	SOURCES redis.cpp
	ADDONS scriptarray scriptdictionary
	SHARED_LIBRARIES ${NVGT_SYSTEM_LIBRARIES} PocoRedis PocoNet PocoFoundation pcre2-8
)
