``` yml
version: "3.9"

services:
  mariadb:
    image: mariadb:10.6
    container_name: ecommerce-mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: ecommerce_db
      MYSQL_USER: ecommerce_user
      MYSQL_PASSWORD: ecommerce_pass
    ports:
      - "3306:3306"
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - ecommerce-network

  backend:
    build:
      context: ./Ecommerce-Backend
      dockerfile: Dockerfile
    container_name: ecommerce-backend
    restart: always
    depends_on:
      - mariadb
    ports:
      - "8081:8080"
    networks:
      - ecommerce-network

  frontend:
    build:
      context: ./Ecommerce-Frontend
      dockerfile: Dockerfile
    container_name: ecommerce-frontend
    restart: always
    depends_on:
      - backend
    ports:
      - "80:80"
    networks:
      - ecommerce-network

networks:
  ecommerce-network:
    driver: bridge

volumes:
  mariadb_data:
```