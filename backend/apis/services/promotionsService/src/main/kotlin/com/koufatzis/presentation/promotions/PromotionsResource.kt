package com.koufatzis.presentation.promotions

import com.koufatzis.presentation.promotions.dtos.Promotion
import kotlinx.coroutines.delay
import java.util.*
import javax.ws.rs.GET
import javax.ws.rs.Path
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType

@Path("/promotions")
class PromotionsResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    suspend fun listPromotions(): List<Promotion> {
        // Small non blocking suspending delay emulating database access
        delay(500)
        return listOf(Promotion((UUID.randomUUID())),
            Promotion((UUID.randomUUID())),
            Promotion((UUID.randomUUID())),
            Promotion((UUID.randomUUID())))
    }
}