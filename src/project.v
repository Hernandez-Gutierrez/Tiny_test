/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`timescale 1ns / 1ps
`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Mapeo de señales de la FSM
  wire a = ui_in[0];
  reg  y;

  // Estados de la máquina (detector de secuencia 1101)
  localparam [2:0] s0 = 3'b000,
                   s1 = 3'b001,
                   s2 = 3'b010,
                   s3 = 3'b011,
                   s4 = 3'b100;

  reg [2:0] state, nextstate;

  // Registro de estado (reset asíncrono activo en bajo: rst_n)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= s0;
    else
      state <= nextstate;
  end

  // Lógica combinacional de siguiente estado
  always @(*) begin
    case (state)
      s0: if (a) nextstate = s1; else nextstate = s0;
      s1: if (a) nextstate = s2; else nextstate = s0;
      s2: if (a) nextstate = s2; else nextstate = s3;
      s3: if (a) nextstate = s4; else nextstate = s0;
      s4: if (a) nextstate = s2; else nextstate = s0;
      default:   nextstate = s0;
    endcase
  end

  // Salida registrada (idéntica a la lógica original)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      y <= 1'b0;
    else
      y <= (nextstate == s4);
  end

  // Asignación de pines de salida (todos los bits deben estar asignados)
  assign uo_out  = {7'b0, y};
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  // Lista de entradas no usadas para evitar warnings en síntesis/lint
  wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule
