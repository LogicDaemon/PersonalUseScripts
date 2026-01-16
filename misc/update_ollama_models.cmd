@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
rem SET "modelsSubdir=LLMs\ollama\models\manifests\registry.ollama.ai\library"
rem )
rem CALL _Distributives.find_subpath.cmd Distributives "%modelsSubdir%" || (
rem 	ECHO Failed to find the ollama models directory.
rem 	EXIT /B 1
rem )
rem SET "modelDir=%Distributives%\%modelsSubdir%"
SET "modelDir=%USERPROFILE%\.ollama\models\manifests\registry.ollama.ai\library"
)
FOR /D %%A IN ("%modelDir%\*") DO @(
	FOR %%B IN ("%%~A\*.*") DO @(
		ECHO Updating "%%~nxA:%%~nxB"
		ollama pull "%%~nxA:%%~nxB" && CALL :addParametrizedVariants "%%~nxA:%%~nxB"
	)
)
EXIT /B

:addParametrizedVariants
@(
	CALL :addContextVariant %1 "%~1-8k" 8192
	CALL :addContextVariant %1 "%~1-32k" 32768
	CALL :addContextVariant %1 "%~1-128k" 131072
	EXIT /B
)

:addContextVariant <base> <variantname> <num_ctx>
@(
	(
		ECHO FROM %~1
		ECHO PARAMETER num_ctx %~3
	) > "%TEMP%\Modelfile"
	ollama create "%~2" --file "%TEMP%\Modelfile"
	DEL "%TEMP%\Modelfile"
	EXIT /B
)
