# AIM NXP 2025 Docker
This is a docker containerized setup for the aim nxp 2025 challenge, because they did not bother to dockerize it.

It installs all the required dependencies, the installed size comes around 30Gigs give or take.
This was a pain in the rear to compile.
Enjoy.

# Install
1) Install `docker` and `docker compose` for your platform.
2) Clone the repo (it has files directly used inside the container
3) Configure workdir inside docker-compose.yml
4) use `docker compose up` inside cloned folder

# Notes
1) This Dockerfile installs ezviz, gazebo, ros and some AiM specific tools which is required for the competition ( cognipilot, cerebrum, etc).
