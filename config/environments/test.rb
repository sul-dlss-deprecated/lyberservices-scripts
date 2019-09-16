Dor::Config.configure do
  dor do
    sleep_time 0
    num_attempts 1
  end

  dor_services do
    url 'https://test'
    token 'test'
  end
end
