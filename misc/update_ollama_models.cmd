@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

SET "modelsSubdir=LLMs\ollama\models\manifests\registry.ollama.ai\library"
)
CALL _Distributives.find_subpath.cmd Distributives "%modelsSubdir%" || (
	ECHO Failed to find the ollama models directory.
	EXIT /B 1
)
FOR /D %%A IN ("%Distributives%\%modelsSubdir%\*") DO @(
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
