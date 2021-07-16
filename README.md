# PHP FPM Exporter for Docker Swarm

Custom PHP image, currently testing [hipages/php-fpm_exporter](https://github.com/hipages/php-fpm_exporter) to use in swarms based on the principles / tech. stack explained in [this blog post](https://www.innoq.com/en/blog/scraping-docker-swarm-service-instances-with-prometheus/).

> todo: test if getting the IP by service discovery is enough on bootup or it needs refreshing/custom `server` endpoint wrapper

Example prometheus file of not-in-swarm-prometheus:

```yml
global:
    scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
    evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
    external_labels:
        monitor: 'cloud-monitor'

scrape_configs:
    - job_name: 'prometheus'
      static_configs:
          - targets: ['localhost:9090']

    # monitors the prometheus master docker host
    - job_name: 'docker'
      static_configs:
          - targets: ['127.0.0.1:9323']
    # monitors the other docker swarm hosts
    - job_name: "sd-docker"
      file_sd_configs:
          - files:
                - "/prometheus_file_sd/target_docker.json"

    #
    # this config enables the master prometheus to scrape data from
    # the prometheus instance which is inside the swarm
    #
    - job_name: 'swarm-prometheus-01'
      honor_labels: true
      metrics_path: '/federate'
      params:
          'match[]':
              # add jobs to import like wanted:
              - '{job="prometheus"}'
              - '{job="php-fpm-exporter"}'
              - '{__name__=~"job:.*"}'
      static_configs:
          - targets:
                # todo: use a swarm manager ip, but should be made dynamic:
                - '10.0.1.8:9090'
```

`prometheus.yml` for the in-swarm-prometheus, assumed to be on the same docker net then the php-fpm exporters:

```yml
global:
    scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
    evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
    external_labels:
        monitor: 'swarm-monitor'

scrape_configs:
    - job_name: 'prometheus'
      static_configs:
          - targets: ['localhost:9090']

    - job_name: 'php-fpm-exporter'
      dns_sd_configs:
          - names:
                # here some of the magic happens!
                #
                # using docker dns service discovery
                # format: tasks.<name-of-stack_service-id>
                # e.g. `docker stack deploy example-app` with a service `php-fpm` will be:
                # tasks.example-app_php-fpm
                - 'tasks.example-app_php-fpm-exporter'
            type: 'A'
            port: 9253
```

Example `docker-compose.yml` of swarm, the `SCRAPE_SERVICE` env variable allows to specify the service that is scraped:

```docker-compose
version: "3.9"

services:
    php-fpm:
        image: hipages/php
        environment:
            PHP_FPM_PM_STATUS_PATH: "/status"
        deploy:
            mode: replicated
            replicas: 3
            placement:
                max_replicas_per_node: 2
        networks:
            - swarm-net

    php-fpm-exporter:
        image: elbakerino/swarm-php-fpm_exporter
        environment:
            # e.g.: `docker stack deploy example-app`:
            # SCRAPE_SERVICE: tasks.example-app_php-fpm
            SCRAPE_SERVICE: tasks.<stack-name>_<php-fpm>
        networks:
            - swarm-net
        ports:
            - '9253:9253'

networks:
    swarm-net:
        external: true
```
## License

This project is free software distributed under the **MIT License**.

See: [LICENSE](LICENSE), © 2021 [Michael Becker](https://mlbr.xyz).

Using a built binary of [hipages/php-fpm_exporter (Apache License 2.0)](https://raw.githubusercontent.com/hipages/php-fpm_exporter/master/LICENSE) in the docker file.


### Contributors

By committing your code/creating a pull request to this repository you agree to release the code under the MIT License attached to the repository.

