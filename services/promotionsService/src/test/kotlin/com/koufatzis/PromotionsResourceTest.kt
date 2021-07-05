package com.koufatzis

import io.quarkus.test.junit.QuarkusTest
import io.restassured.RestAssured.given
import org.junit.jupiter.api.Test

@QuarkusTest
class PromotionsResourceTest {

    @Test
    fun testHelloEndpoint() {
        given()
            .`when`().get("/promotions")
            .then()
            .statusCode(200)
    }
}