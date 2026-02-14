package com.monarch.ledger;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.monarch.ledger", "com.monarch.common"})
public class CashLedgerApplication {
    public static void main(String[] args) {
        SpringApplication.run(CashLedgerApplication.class, args);
    }
}
