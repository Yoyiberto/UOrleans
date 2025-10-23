# Data Fusion for Mobile Robot Localization (Kalman Filter)

This repository contains projects and exercises focused on state estimation and sensor fusion for localizing a mobile robot in a 2D environment. The primary technique explored is the **Extended Kalman Filter (EKF)**, applied to different sensor modalities and fusion architectures.

## Summary

The core objective is to accurately estimate the robot's state, defined by its position `(x, y)` and its heading `θ`, by fusing data from various sensors. We use a simple unicycle kinematic model to predict the robot's motion and sensor measurements to correct this prediction. The non-linear nature of the measurement models necessitates the use of an Extended Kalman Filter (EKF) rather than a standard Kalman Filter.

---

## Project 1: Localization using Multilateration (UWB TOF)

### Objective

To estimate the robot's 2D position and heading by fusing velocity commands with distance measurements obtained from three beacons of known positions using Time of Flight (TOF) sensors.

### Core Concepts
*   **Mobile Robot Kinematics:** Modeling the motion of the robot based on translational and angular velocities.
*   **Multilateration:** Determining the position of a point by measuring its distance from multiple known points (beacons).
*   **Time of Flight (TOF):** A sensing method used to measure distance by calculating the time it takes for a signal to travel between a transmitter and a receiver.
*   **Extended Kalman Filter (EKF):** A version of the Kalman filter used for non-linear systems, which linearizes the system around the current state estimate.

### System Model

The state of the robot at any time `k` is represented by the vector:
$$
X_k = \begin{bmatrix} x_k \\ y_k \\ \theta_k \end{bmatrix}
$$

#### 1. Evolution Model (State Equation)
The continuous-time kinematic model is given by:
$$
\begin{cases}
\dot{x} = u \cos(\theta) \\
\dot{y} = u \sin(\theta) \\
\dot{\theta} = \omega
\end{cases}
$$
Using Euler's method for discretization with a time step $\Delta t$, we get the discrete-time state equation:
$$
X_{k+1} = f(X_k, u_k) = \begin{bmatrix} x_k + u_k \cos(\theta_k) \Delta t \\ y_k + u_k \sin(\theta_k) \Delta t \\ \theta_k + \omega_k \Delta t \end{bmatrix}
$$

#### 2. Measurement Model (Output Equation)
The sensor measures the distance from the robot $M(x, y)$ to three beacons $B_i(x_{b_i}, y_{b_i})$. The measurement vector $Z_k$ consists of these three distances:
$$
Z_k = \begin{bmatrix} d_1 \\ d_2 \\ d_3 \end{bmatrix} = h(X_k) = \begin{bmatrix} \sqrt{(x_k - x_{b_1})^2 + (y_k - y_{b_1})^2} \\ \sqrt{(x_k - x_{b_2})^2 + (y_k - y_{b_2})^2} \\ \sqrt{(x_k - x_{b_3})^2 + (y_k - y_{b_3})^2} \end{bmatrix}
$$
This equation is non-linear, which is why an EKF is required.

---

## Project 2: Multimodal & Distributed Data Fusion

### Objective
To robustly estimate the robot's position and orientation by implementing a **distributed filter**. This involves fusing asynchronous measurements from three different sensor types: an IMU, an angulation sensor, and a Time Difference of Arrival (TDOA) sensor.

### Core Concepts
*   **Multimodal Sensor Fusion:** Combining data from different types of sensors to achieve a more accurate and reliable state estimate than could be obtained from any single sensor.
*   **Inertial Measurement Unit (IMU):** Measures the robot's orientation (heading `θ`).
*   **Angulation (Angle of Arrival):** Measures the angle at which signals from known beacons arrive at the robot.
*   **Time Difference of Arrival (TDOA):** Measures the difference in distance to two beacons, which defines a hyperbola on which the robot must lie.
*   **Distributed Filtering:** An architecture where each sensor runs its own local Kalman filter. The state estimates from these local filters are then sent to a central fusion center, which combines them to produce a final, global state estimate.
*   **Asynchronous Fusion:** A technique to handle sensors that provide data at different rates and times.

### System Model

The evolution model is the same discrete-time model as in Project 1.

#### Measurement Models
We have three distinct measurement models, one for each sensor type.

1.  **Type M (IMU):** Measures heading directly.
    ```math
    z_M = \theta
    ```
2.  **Type B (Angulation):** Measures the angle $\alpha_l$ of an incoming signal from beacon $B_l(x_l, y_l)$.
    ```math
    z_B = \alpha_l = \arctan\left(\frac{y - y_l}{x - x_l}\right)
    ```
3.  **Type T (TDOA):** Measures the difference in distance between the robot and two beacons, $B_i$ and $B_j$.
    ```math
    z_T = \Delta d_{(i,j)} = \sqrt{(x - x_i)^2 + (y - y_i)^2} - \sqrt{(x - x_j)^2 + (y - y_j)^2}
    ```

### Implementation: Distributed Filter & Asynchronous Data

A key challenge in this project is handling the different sampling rates of the sensors. The distributed filter architecture addresses this naturally. The implementation strategy is as follows:

1.  **Local Filters:** An independent EKF is implemented for each of the three sensor modalities (IMU, Angulation, TDOA).
2.  **Prediction Step:** The prediction step for all filters runs at the highest frequency of the system or at a fixed base rate.
3.  **Update Step:** The update (or correction) step for a specific local filter is only executed when a new measurement from its corresponding sensor arrives.
4.  **State Fusion:** The state estimates and covariances from the local filters are periodically sent to a fusion center. The fusion center uses an algorithm (e.g., Covariance Intersection, Simple Average) to combine these estimates into a single, more accurate global state estimate.
