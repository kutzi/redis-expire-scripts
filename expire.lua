local expired=0;

for i,k in ipairs(KEYS) do
    local ttl=redis.call('ttl', k);
    if ttl == -1 then
        redis.call('EXPIRE', k, 60)
        expired = expired + 1;
    end
end

return "Expired " .. expired .. " keys";
