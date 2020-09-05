package com.linuxacademy.prometheusdd.clientlibexample;

import io.prometheus.client.Counter;
import io.prometheus.client.exporter.HTTPServer;
import java.io.IOException;

public class Main {

    static final Counter currentCount = Counter.build()
        .name("current_count").help("Current count.").register();

    public static void main(String[] args) throws InterruptedException {
        try {
            HTTPServer server = new HTTPServer(8081);
        } catch (IOException e) {
            System.out.println("Failed to start metrics endpoint.");
            e.printStackTrace();
        }

        System.out.println("Counting to 1000...");
        for (int i = 0; i <= 1000; i++) {
            System.out.println(i);
            currentCount.inc();
            Thread.sleep(1000);
        }
        System.out.println("Done counting!");
    }

}