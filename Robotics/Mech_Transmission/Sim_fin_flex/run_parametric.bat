@echo off
echo ============================================
echo Finger Gripper Parametric Analysis
echo ============================================
echo.

if not exist .venv (
    echo Creating virtual environment...
    python -m venv .venv
    echo.
)

echo Installing dependencies...
.venv\Scripts\python.exe -m pip install -q -r requirements.txt
echo.

echo Running parametric simulation...
echo.
.venv\Scripts\python.exe gripper_simulation.py

echo.
echo ============================================
echo Done! Check output PNG and CSV files.
echo ============================================
pause
