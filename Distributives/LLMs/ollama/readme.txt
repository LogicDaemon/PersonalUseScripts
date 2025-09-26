gpt4all → olama endpoint: http://127.0.0.1:11434/v1


ollama run llama3.1
>>> /set parameter num_ctx 4096
Set parameter 'num_ctx' to '4096'
>>> /save llama3.1-4k

>ollama run gemma3:4b
>>> /set parameter num_ctx 131072
Set parameter 'num_ctx' to '131072'
>>> /save gemma3:4b-128k
Created new model 'gemma3:4b-128k'
>>> /bye

/set parameter num_ctx 131072

llama3.1_ctx_4096:
```
FROM llama3.1:latest 
PARAMETER num_ctx 4096
```

`ollama create llama3.1_ctx_4096 -f llama3.1_ctx_4096`
