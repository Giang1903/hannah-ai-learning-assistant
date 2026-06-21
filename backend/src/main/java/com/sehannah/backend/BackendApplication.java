package com.sehannah.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * SE Hannah Backend Service
 * Phu trach: Quan ly User, Course, Document, Community, Notification
 * Khong xu ly logic AI - phan do thuoc ve AI Service (FastAPI rieng)
 */
@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }

}
