@echo off
echo ============================================
echo Finger Gripper FEA Visualization
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

echo Running FEA stress visualization...
echo.
.venv\Scripts\python.exe fea_visualization.py

echo.
echo ============================================
echo Done! Check output PNG files.
echo ============================================
pause
