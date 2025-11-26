set.seed(11071995)

devtools::load_all()

gabarito_amostra <- da_report |>
  dplyr::filter(model == "gemini-2.5-pro") |>
  dplyr::transmute(
    id_processo = basename(path),
    escopo,
    gratuidade_pedida,
    gratuidade_concedida,
    julgamento_final,
    valor_condenacao,
    percentual_sucumbencia,
    custas,
    pedidos
  ) |>
  dplyr::filter(escopo) |>
  dplyr::sample_n(50)

gabarito_amostra$model <- "analise_manual"
gabarito_amostra <- gabarito_amostra |> head(20)

niveis <- c("horas_extras", "adicional_periculosidade", "adicional_insalubridade", "ferias", "verbas_rescisorias", "reconhecimento_vinculo", "13_salario", "aviso_previo", "multas_fgts", "danos_morais", "recolhimento_fgts", "justa_causa", "honorarios_advogado", "outro")

gabarito_amostra

# processo 1

gabarito_amostra$id_processo[1]
gabarito_amostra$pedidos[[1]]
gabarito_amostra$valor_condenacao[1]
gabarito_amostra$custas[1]
gabarito_amostra$percentual_sucumbencia[1]
gabarito_amostra$gratuidade_concedida[1]
gabarito_amostra$gratuidade_pedida[1]

# processo 2

# achar os pedidos desses processo não está fácil, porque a sentença lista
# 1. saldo de salário de novembro/21 (22 dias)
# 2. aviso prévio proporcional de 36  dias;
# 3. 13º salário proporcional de 2021, 12/12, já observada a projeção do aviso prévio indenizado;
# 4. férias 2019/2020 (em dobro), 2020/2021 (simples) e proporcionais, 2021/2022, 03/12,
# todas  acrescidas do terço constitucional, já observada   projeção do aviso prévio;
# 5. multa do artigo 477, §8º da CLT;
# 6. depósitos de FGTS de todo o período contratual supra reconhecido, inclusive

# esses 6 primeiros pedidos estão contemplados + o pedido de reconhecimento de
# vínculo

# os pedidos de danos morais e da expedição de um ofício são realmente
# improcedentes.

# o pedido de horas extras parece que não foi feito, embora tenha sido concedido.
# parece que não teve pedido de intervalo intrajornarda, mas foi concedido.
# a jornada foi fixada direto

gabarito_amostra$pedidos[[2]]
gabarito_amostra$valor_condenacao[2]
gabarito_amostra$custas[2]
gabarito_amostra$percentual_sucumbencia[2]
gabarito_amostra$gratuidade_concedida[2]
gabarito_amostra$gratuidade_pedida[2]

# processo 3

# correto

gabarito_amostra$pedidos[[3]]
gabarito_amostra$valor_condenacao[3]
gabarito_amostra$custas[3]
gabarito_amostra$percentual_sucumbencia[3]
gabarito_amostra$gratuidade_concedida[3]
gabarito_amostra$gratuidade_pedida[3]

# processo 4

# justa causa foi anulada mesmo, é o "primeiro pedido" embora não esteja na lista
# aviso previo foi concedido
# ferias foi concedida
# 13o foi concedido
# deposito faltante de fgts foi concedido
# a multa do fgts foi concedida
# o pagamento de saldo de salario foi indeferido mesmo
# os pedidos "multas do 477 e 467" foram feitos e deveriam ter caído em "verbas rescisorias"
# nesse processo teve sucumbência recíproca, em um caso foi 5 e em outro foi 10
# a gente deveria fazer um código "sucumbência recíproca"

gabarito_amostra$id_processo[4]
gabarito_amostra$pedidos[[4]]$categoria <- structure(c(12L, 8L, 4L, 7L, 11L, 9L, 5L, 5L, 5L, 14L, 13L), levels = c("horas_extras",
                                                                                                                   "adicional_periculosidade", "adicional_insalubridade", "ferias",
                                                                                                                   "verbas_rescisorias", "reconhecimento_vinculo", "13_salario",
                                                                                                                   "aviso_previo", "multas_fgts", "danos_morais", "recolhimento_fgts",
                                                                                                                   "justa_causa", "honorarios_advogado", "outro"), class = "factor")
gabarito_amostra$valor_condenacao[4]
gabarito_amostra$custas[4]
gabarito_amostra$percentual_sucumbencia[4]
gabarito_amostra$gratuidade_concedida[4]
gabarito_amostra$gratuidade_pedida[4]

# processo 5

# nesse caso deveria ter o pedido de reflexos...
# nem tanto pela palavra "reflexo", mas sim porque
# o esperado seria
# "Improcedem, consequentemente, os pedidos de reflexos das
#diferenças em outras verbas, como FGTS, férias, 13° salário, verbas rescisórias,
#repouso semanal remunerado e adicional por tempo de serviço."
# no processo 1 "reflexos" entrou dentro da descrição do pedido "horas_extras"

incluir <- tibble::tibble(
  categoria = factor("outro", levels = niveis),
  breve_descricao = "pedidos de reflexos das diferenças em outras verbas, como FGTS, férias, 13° salário, verbas rescisórias, repouso semanal remunerado e adicional por tempo de serviço",
  decisao_pedido = "improcedente"
)

gabarito_amostra$pedidos[[5]] <- dplyr::bind_rows(gabarito_amostra$pedidos[[5]], incluir)
gabarito_amostra$valor_condenacao[5]
gabarito_amostra$custas[5]
gabarito_amostra$percentual_sucumbencia[5] <- NA
gabarito_amostra$gratuidade_concedida[5]
gabarito_amostra$gratuidade_pedida[5]

# aqui teve sucumbencia reciproca tb, então não tem como fixar em 5 ou 10 só

# processo 6

# para ser ultra consistente ele deveria ter separado o aviso prévio.
# entretanto, o aviso prévio é uma das verbas rescisórias, de tal forma
# que não houve "erro" na classificação no que diz respeito a fixar
# "verbas_rescisorias" como uma grande categoria incluindo
# aviso prévio e tal.

# de toda forma separando todas as verbas rescisorias concedidas ficaria assim:

incluir <- tibble::tibble(
  categoria = factor(c("aviso_previo", "verbas_rescisorias", "ferias"), levels = niveis),
  breve_descricao = c("aviso prévio de 36 (trinta e seis) dias;", "saldo de salário de 1 (um) dia referente ao mês de dezembro/2022; - quebra de caixa do mês de dezembro/2022; - 13º salário sobre o aviso prévio indenizado;", "férias sobre o abiso prévio"),
  decisao_pedido = c("procedente", "procedente", "procedente")
)

# isso acontece em outros processos dessa análise, então para ficar como um gabarito mesmo
# vou incluir

# a IA já separou as multas como "outro", mas isso está errado mesmo.
# multas do 467 e 477 são de fato "verbas_rescisorias". Em outras
# classificações a IA fez diferente

gabarito_amostra$id_processo[6]
gabarito_amostra$pedidos[[6]]$categoria[c(2,3)] <- "verbas_rescisorias"

gabarito_amostra$pedidos[[6]] <- gabarito_amostra$pedidos[[6]][-1,] |>
  dplyr::bind_rows(incluir)

gabarito_amostra$valor_condenacao[6]
gabarito_amostra$custas[6]
gabarito_amostra$percentual_sucumbencia[6]
gabarito_amostra$gratuidade_concedida[6]
gabarito_amostra$gratuidade_pedida[6]

# processo 7

# multa do artigo 477 tem que ser contado como "verbas_rescisorias"
# de resto os pedidos estão corretos

gabarito_amostra$pedidos[[7]]$categoria[7] <- "verbas_rescisorias"
gabarito_amostra$id_processo[7]
gabarito_amostra$valor_condenacao[7]
gabarito_amostra$custas[7]
gabarito_amostra$percentual_sucumbencia[7]
gabarito_amostra$gratuidade_concedida[7]
gabarito_amostra$gratuidade_pedida[7]

# processo 8

# aqui a multa do artigo 477 foi enquadrada como 'verbas_rescisorias'
# isso está correto

# aqui teve sucumbencia reciproca de 10% pra cada lado.

gabarito_amostra$id_processo[8]
gabarito_amostra$pedidos[[8]]
gabarito_amostra$valor_condenacao[8]
gabarito_amostra$custas[8]
gabarito_amostra$percentual_sucumbencia[8]
gabarito_amostra$gratuidade_concedida[8]
gabarito_amostra$gratuidade_pedida[8]

# processo 9

# nesse aqui a IA errou feio. teve "reflexos" no adicional de insalubridade,
# mas eles não foram capturados. foi capturado como "horas_extras",
# que é um erro grave. Não fizemos uma categoria para "jornada de trabalho"
# então teria que cair em "outros". Esse pedido de fato não foi concedido.

# o erro é meio grave porque o reflexo do adicional de insalubridade nas horas
# extras foi concedido.

gabarito_amostra$id_processo[9]
gabarito_amostra$pedidos[[9]]$categoria[2] <- factor("outro", niveis)
gabarito_amostra$valor_condenacao[9]
gabarito_amostra$custas[9]
gabarito_amostra$percentual_sucumbencia[9]
gabarito_amostra$gratuidade_concedida[9]
gabarito_amostra$gratuidade_pedida[9]

# processo 10

# correto

gabarito_amostra$id_processo[10]
gabarito_amostra$pedidos[[10]]
gabarito_amostra$valor_condenacao[10]
gabarito_amostra$custas[10]
gabarito_amostra$percentual_sucumbencia[10]
gabarito_amostra$gratuidade_concedida[10]
gabarito_amostra$gratuidade_pedida[10]

# processo 11

# correto, mas o aviso prévio, as férias etc deveriam ter ficado
# separadas porque estavam assim no lá na decisão...

incluir <- tibble::tibble(
  categoria = factor(c("verbas_rescisorias", "aviso_previo", "ferias"), levels = niveis),
  breve_descricao = c("saldo de salário de 12 dias em outubro de 2020; FGTS sobre o aviso prévio (Súmula 305 do TST)",
                      "aviso prévio de 30 dias;",
                      "férias simples de 2019/2020, acrescidas do terço constitucional;férias proporcionais, acrescidas do terço constitucional;"),
  decisao_pedido = c("procedente", "procedente", "procedente")
)

gabarito_amostra$id_processo[11]
gabarito_amostra$pedidos[[11]] <- gabarito_amostra$pedidos[[11]][-1,] |>
  dplyr::bind_rows(incluir)
gabarito_amostra$valor_condenacao[11]
gabarito_amostra$custas[11]
gabarito_amostra$percentual_sucumbencia[11]
gabarito_amostra$gratuidade_concedida[11]
gabarito_amostra$gratuidade_pedida[11]

# processo 12

# correto

gabarito_amostra$id_processo[12]
gabarito_amostra$pedidos[[12]]
gabarito_amostra$valor_condenacao[12]
gabarito_amostra$custas[12]
gabarito_amostra$percentual_sucumbencia[12]
gabarito_amostra$gratuidade_concedida[12]
gabarito_amostra$gratuidade_pedida[12]

# processo 13

# correto. esse é exatamente o que deveria sair

gabarito_amostra$id_processo[13]
gabarito_amostra$pedidos[[13]]
gabarito_amostra$valor_condenacao[13]
gabarito_amostra$custas[13]
gabarito_amostra$percentual_sucumbencia[13]
gabarito_amostra$gratuidade_concedida[13]
gabarito_amostra$gratuidade_pedida[13]
gabarito_amostra$julgamento_final[13]

# processo 14

# correto, mas aqui tem um ponto.

# aparentemente existe um "item 7 do rol de pedidos da petição inicial"

# a PI provavelmente estrutura os pedidos em itens. o pedido principal parece
# ser o de horas extras e de intervalo, mas o cara deve estar pedindo
# reflexos no FGTS, na multa, na rescição etc

gabarito_amostra$id_processo[14]
gabarito_amostra$pedidos[[14]]
gabarito_amostra$valor_condenacao[14]
gabarito_amostra$custas[14]
gabarito_amostra$percentual_sucumbencia[14]
gabarito_amostra$gratuidade_concedida[14]
gabarito_amostra$gratuidade_pedida[14]
gabarito_amostra$julgamento_final[14]

# processo 15

# o vinculo não foi reconhecido então os outros pedidos foram ignorados

gabarito_amostra$id_processo[15]
gabarito_amostra$pedidos[[15]]
gabarito_amostra$valor_condenacao[15]
gabarito_amostra$custas[15]
gabarito_amostra$percentual_sucumbencia[15]
gabarito_amostra$gratuidade_concedida[15]
gabarito_amostra$gratuidade_pedida[15]
gabarito_amostra$julgamento_final[15]

# processo 16

# outro exemplo perfeito

gabarito_amostra$id_processo[16]
gabarito_amostra$pedidos[[16]]
gabarito_amostra$valor_condenacao[16]
gabarito_amostra$custas[16]
gabarito_amostra$percentual_sucumbencia[16]
gabarito_amostra$gratuidade_concedida[16]
gabarito_amostra$gratuidade_pedida[16]
gabarito_amostra$julgamento_final[16]

# processo 17

# de novo poderia ter quebrado mais. a sentença explicitamente
# defere separado "saldo de salário" e "adicional de insalubridade" por exemplo

incluir <- tibble::tibble(
  categoria = factor(c("verbas_rescisorias", "adicional_insalubridade", "outro",
                       "13_salario", "ferias", "verbas_rescisorias"), levels = niveis),
  breve_descricao = c("Saldo de salário, R$2.723,44 (TRCT);",
                      "Adicional de Insalubridade, R$209,00 (TRCT);",
                      "Adicional Noturno, R$460,00 (TRCT);",
                      "13º salário 10/12 avos de 2020, R$4.117,66 (TRCT);",
                      "Férias + 1/3, 2019/20, R$6.885,58, 2020 R$3.228,29 (TRCT);",
                      "Multas dos artigos 477 (R$4.842,44) e 467 (incidente em saldo de salário, férias + 1/3 e 13º salário) da CLT."),
  decisao_pedido = c("procedente", "procedente", "procedente", "procedente", "procedente", "procedente")
)

gabarito_amostra$id_processo[17]
gabarito_amostra$pedidos[[17]] <- gabarito_amostra$pedidos[[17]][-1,] |>
  dplyr::bind_rows(incluir)
gabarito_amostra$valor_condenacao[17]
gabarito_amostra$custas[17]
gabarito_amostra$percentual_sucumbencia[17]
gabarito_amostra$gratuidade_concedida[17]
gabarito_amostra$gratuidade_pedida[17]
gabarito_amostra$julgamento_final[17]

# processo 18

# essa é complicada. teve reflexos nas férias e no fgts, então esses pedidos
# deveriam ser explicitados.

# teve sucumbencia reciproca

incluir <- tibble::tibble(
  categoria = factor(c("ferias", "recolhimento_fgts", "fgts"), levels = niveis),
  breve_descricao = c("reflexos deferidos em férias acrescidas de 1/3 e FGTS.",
                      "reflexos deferidos em férias acrescidas de 1/3 e FGTS.",
                      "reflexos deferidos em férias acrescidas de 1/3 e FGTS."),
  decisao_pedido = c("procedente", "procedente", "procedente")
)

gabarito_amostra$id_processo[18]
gabarito_amostra$pedidos[[18]] <- dplyr::bind_rows(gabarito_amostra$pedidos[[18]], incluir)
gabarito_amostra$valor_condenacao[18]
gabarito_amostra$custas[18]
gabarito_amostra$percentual_sucumbencia[18] <- NA
gabarito_amostra$gratuidade_concedida[18]
gabarito_amostra$gratuidade_pedida[18]
gabarito_amostra$julgamento_final[18]

# processo 19

# aviso prévio e multa do fgts deveria deveria estar separado

incluir <- tibble::tibble(
  categoria = factor(c("aviso_previo", "multa_fgts"), levels = niveis),
  breve_descricao = c("aviso prévio indenizado de 39 dias;",
                      "40% (Súmula n. 461/TST)"),
  decisao_pedido = c("procedente", "procedente")
)

gabarito_amostra$id_processo[19]

gabarito_amostra$pedidos[[19]]$categoria[6] <- "verbas_rescisorias"
gabarito_amostra$pedidos[[19]] <- dplyr::bind_rows(gabarito_amostra$pedidos[[19]], incluir)
gabarito_amostra$valor_condenacao[19]
gabarito_amostra$custas[19]
gabarito_amostra$percentual_sucumbencia[19]
gabarito_amostra$gratuidade_concedida[19]
gabarito_amostra$gratuidade_pedida[19]
gabarito_amostra$julgamento_final[19]

# processo 20

# está correto

gabarito_amostra$id_processo[20]
gabarito_amostra$pedidos[[20]]
gabarito_amostra$valor_condenacao[20]
gabarito_amostra$custas[20]
gabarito_amostra$percentual_sucumbencia[20]
gabarito_amostra$gratuidade_concedida[20]
gabarito_amostra$gratuidade_pedida[20]
gabarito_amostra$julgamento_final[20]


# salvando dados manuais --------------------------------------------------

gabarito_manual <- gabarito_amostra

usethis::use_data(gabarito_manual)
