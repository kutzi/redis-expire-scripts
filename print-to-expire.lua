local expire=0;

for i,k in ipairs(KEYS) do
    local ttl=redis.call('ttl', k);
    -- redis.log(redis.LOG_NOTICE, k .. ": ttl=" .. ttl);
    if ttl == -1 or ttl > 86400 then -- no expiry at all or longer than 1 day
        expire = expire + 1;
    end
end

return expire;
