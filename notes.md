#### 24/04/2024

Curso de SwiftUI: identificando erros em suas requisições

@01-Identificando os erros de uma requisição

@@01
Apresentação

Olá, gostaria de dar as boas-vindas a você que está iniciando mais um curso de IOS na Alura.
Audiodescrição: Ândriu Coelho é um homem branco de olhos castanhos e cabelo castanho-claro. Tem barba e bigode e usa uma camiseta azul-escura com o logotipo da Alura. Ao fundo, estúdio com iluminação gradiente do rosa para o azul. À direita, uma estante com decorações.
O que vamos aprender?
A ideia desse curso é continuar o desenvolvimento do aplicativo Vollmed, onde podemos procurar por especialistas e agendar uma consulta. Agora, vamos utilizar outro tópico, que é o tratamento de erros. O objetivo é pensar em casos de uso com caminhos alternativos.

Até então, estávamos focados no happy path (caminho feliz), mas sabemos que um aplicativo pode enfrentar instabilidade, ter problemas de conexão, e ocorrer vários tipos de erro no dia a dia. Nós, como pessoas desenvolvedoras, devemos saber tratar esses erros.

Vamos começar o curso configurando o Apiary, uma ferramenta em que podemos mockar (simular) uma resposta do back-end. Começaremos falando sobre status code, mais especificamente sobre erro 400. Vamos forçar um erro 400 utilizando o Apiary para verificar como o aplicativo se comporta.

Com base nisso, vamos avançar construindo um Snackbar de erro.

Snackbar de erro na parte inferior do aplicativo da Vollmed. Caixa de fundo vermelho e fonte branca com o texto: "Ops! Ocorreu um erro, mas já estamos trabalhando para solucionar".

Snackbar de erro é uma view que podemos utilizar para diferentes situações dentro do aplicativo, incluindo mostrar um erro. Podemos mostrar uma view com uma mensagem para a pessoa usuária entender o que está acontecendo. É muito importante manter a pessoa usuária sempre informada.

Feito isso, partiremos para outro tópico importante em nosso curso, que é o Skeleton. Quando abrimos o aplicativo e aparece uma view de carregamento, chamamos de Skeleton.

Skeleton da página inicial do aplicativo Vollmed. Uma silhueta cinza de um círculo e linhas estão no exato local onde ficarão a fotografia e demais informações de especialistas.

O aplicativo pode demorar para trazer informações, e é importante manter a pessoa usuária sabendo do que está acontecendo, mostrando que o aplicativo está tentando carregar as informações.

Pré-requisitos
Como pré-requisito, é importante que você tenha conhecimento em SwiftUI, ou que tenha feito os cursos da nossa formação sobre SwiftUI na Alura.

Esperamos que você tenha gostado dos tópicos que aprenderemos durante o curso. Até a primeira aula!

@@02
Preparando o ambiente: Vollmed

Esse projeto será uma continuação da Vollmed e partiremos do ponto em que o curso iOS com SwiftUI: Aplicando o padrão arquitetural MVVM parou. Por isso, é importante que você já tenha o projeto em sua máquina.
Baixe o projeto inicial ou acesse o repositório no GitHub e pegue o projeto da branch main.

Xcode 15
Certifique-se de que tem a IDE XCode instalado na sua máquina. Caso ainda não tenha, pode baixá-lo diretamente da AppStore ou no site oficial da Apple para desenvolvedores.

Lembrando que o Xcode só está disponível para sistema operacional MacOS!
Neste curso, estaremos utilizando o Xcode na versão 15. No momento de gravação deste curso, a versão 15 ainda estava em beta, ou seja, não estava disponível para todo mundo ainda.

Entretanto, quando você estiver assistindo este curso, muito provavelmente a versão 15 já estará disponível para todos os usuários e você poderá fazer o download tranquilamente.

https://github.com/alura-cursos/swiftui-vollmed-authentication.git

https://cursos.alura.com.br/course/swift-padrao-arquitetural-mvvm-separacao-responsabilidades

https://github.com/alura-cursos/ios-mvvm-pattern/archive/refs/heads/aula-5.zip

https://github.com/alura-cursos/ios-mvvm-pattern/tree/aula-5

https://apps.apple.com/br/app/xcode/id497799835

https://developer.apple.com/xcode/

@@03
Gerenciando erros em aplicativos

Para iniciar nosso curso, vamos dar continuidade ao Vollmed, um aplicativo onde conseguimos procurar por especialistas, como médicos, e agendar consultas.
Este projeto foi desenvolvido no decorrer dos cursos anteriores dessa formação. Se você não acompanhou o passo a passo, pode voltar nos cursos anteriores para verificar como foi desenvolvido.

Status Code
Até então, trabalhamos primariamente com o happy path (caminho feliz). No entanto, sabemos que um aplicativo pode se tornar instável, porque não depende apenas dele. Fazemos requisições para servidores, dependemos de conexão com a internet, portanto, há vários problemas que podem acontecer.

A ideia neste curso é começar a trabalhar esses cenários. Daremos ênfase na importância de fornecer feedback para a pessoa usuária sobre o que está acontecendo no aplicativo.

Provavelmente, você já deve ter tido a experiência de usar algum aplicativo em que a tela travamos ou não entendeu o que estava acontecendo. Naquela ocasião, o problema poderia ter sido um erro não tratado ou internet lenta. Em todas essas situações, é importante manter a pessoa usuária informado sobre o que está acontecendo.

No curso em que falamos brevemente sobre o padrão arquitetural, começamos a mencionar sobre erros, mas não exploramos a fundo. No arquivo RequestError que temos em "Vollmed > Networking > Base", já mapeamos alguns casos de erro.

RequestError.swift:
enum RequestError: Error {
        case decode
        case invalidURL
        case noResponse
        case unauthorized
        case unknown
        case custom(error: [String: Any]?)

        var customMessage: String {
                switch self {
                case .decode:
                        return "erro de decodificação"
                case .unauthorized:
                        return "sessão expirada"
                default:
                        return "erro desconhecido"
                }
        }
}
COPIAR CÓDIGO
Portanto, temos casos de erros como decodificação, URL inválida , sem resposta, não autorizado e erro desconhecido. Apesar de mapear alguns dos possíveis erros, não mostramos para a pessoa usuária o problema que está ocorrendo. Neste curso, vamos prosseguir a partir disso.

Para começar, falaremos sobre alguns status codes mais conhecidos.

No menu lateral esquerdo, abrimos o arquivo HTTPClient também dentro da pasta "Base". Nele, temos um switch/case que valida o de acordo com o statusCode.

HTTPClient.swift:
switch response.statusCode {

case 200...299:
        guard let responseModel = responseModel else {
                return .success(nil)
        }

        guard let decodedResponse = try? JSONDecoder().decode(responseModel, from: data) else {
                return .failure(.decode)
        }

        return .success(decodedResponse)
case 400:
        let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        return .failure(.custom(error: errorResponse))
case 401:
        return .failure(.unauthorized)

default:
        return .failure(.unknown)
}
COPIAR CÓDIGO
Relembrando, o status code é um código, geralmente de três dígitos, que o back-end retorna para o client (no nosso caso, o aplicativo), informando o que aconteceu em uma requisição.
Os status codes da classe 200 a 299 geralmente indicam sucesso. Nesse arquivo já temos um caso de erro mapeado, que é o 401, quando não é autorizado, ou seja, quando tentamos fazer uma requisição e o token da pessoa usuária está inválido ou algo similar. Com base nesse status code, podemos tratar alguns erros.

Neste curso, vamos utilizar uma ferramenta chamada Apiary. Esta ferramenta é utilizada para documentar APIs e para simular (mock) a resposta de uma API.
É muito utilizada em equipes de desenvolvimento mobile, porque muitas vezes começamos a implementação e a equipe de back-end ainda não concluiu todo o desenvolvimento. Assim, conseguimos simular algumas respostas para consumir no front-end, no nosso caso, no nosso aplicativo.

Novo projeto no Apiary
Para começar, vamos abrir o navegador e procurar pela Apiary. Vamos acessar o primeiro link, que é a página oficial do Apiary. Para acessar a ferramenta, é necessário ter uma conta no GitHub.

Como já estamos logados na nossa conta, podemos clicar em "Continue" no canto superior direito para redirecionar a um projeto com um template padrão.

Vamos criar um novo projeto. Portanto, na barra superior esquerda, onde temos o nome da conta logada, vamos clicar no botão para expandir as opções. Em seguida, vamos clicar no botão verde "Create New API Project" para criar uma nova API. Com isso, podemos dar um nome para o projeto. Vamos nomeá-lo voll-med-api-erros e clicar em "Create API".

Depois de clicar, ele traz as configurações do Apiary à esquerda e algumas informações sobre o projeto à direita.

Modelo padrão das configurações do Apiary
# voll-med-api-erros

Polls is a simple API allowing consumers to view polls and vote in them.

## Questions Collection [/questions]

### List All Questions [GET]

+ Response 200 (application/json)
        [
                {
                        "question": "Favamosrite programming language?",
                        "published_at": "2015-08-05T08:40:51.6202",
                        "choices": [
                                {
                                        "choice": "Swift",
                                        "votes": 2048
                                },
                                {
                                        "choice": "Python",
                                        "votes": 1024
                                },
                                {
                                        "choice": "Objective-C",
                                        "votes": 512
                                },
                                {
                                        "choice": "Ruby",
                                        "votes": 256
                                }
                        ]
                }
        ]
        
### Create a New Question [POST]

(restante omitido…)
COPIAR CÓDIGO
Podemos configurá-lo de várias maneiras, mas vamos começar simulando um erro no caso de agendar uma consulta com uma pessoa especialista. Ou seja, quando fazemos um GET para médicos especialistas. Por exemplo, vamos simular um erro clássico que pode acontecer, o erro 400.

Como fazemos para simular esse erro? No lado esquerdo do painel do Apiary, temos uma Response com o status code 200. Vamos alterar para 400. Portanto, vamos criar um mock que simula um erro 400 no nosso servidor.

Em List All Questions, configuramos o verbo da requisição, que continuará como GET.

E em Questions Collection é a rota da nossa API. Nesse caso, está a /questions, porque é um padrão que ele já traz. Mas vamos mudar para /specialists que significa especialista em inglês, conforme adotamos no projeto.

## Questions Collection [/specialists]

### List All Questions [GET]

+ Responde 400 (application/json)
COPIAR CÓDIGO
Assim, quando se fizer um /specialists, ele retornará um erro 400. E, logo abaixo, podemos configurar um JSON de erro. Isso, geralmente, é acordado com a equipe de back-end, que define qual será o JSON de erro que eles vão enviar. Você pode inseri-lo nesse espaço para simular este comportamento.

Dica: ao usar a Apiary é importante manter dois "Tabs" de distância para configurar o código corretamente.
Vamos criar um JSON de erro. Após dois "Tabs", abrimos chaves para começar a criar um objeto de erro. Portanto, digitamos error entre aspas, seguido de dois-pontos e chaves.

Dentro destas chaves, vamos criar um objeto de erro. Primeiro, vamos enviar o código. Para isso, escrevemos code como 400, que é o status code de erro.

Também enviaremos uma mensagem, usando message. Poderíamos colocar qualquer mensagem. Nesse caso, vamos usar uma mensagem padrão para começar os nossos estudos. Entre aspas, escrevemos Ops! Ocorreu um erro, mas já estamos trabalhando para solucionar. Essa é a mensagem de erro inicial com a qual vamos trabalhar.

+ Responde 400 (application/json)

        {
            "error": {
                "code": 400,
                "message": "Ops! Ocorreu um erro, mas já estamos trabalhando para solucionar",
            }
        }
COPIAR CÓDIGO
Em Create a New Question, temos o POST que não vamos utilizar. Portanto, podemos apagar desde esse título na linha 21 em diante.

Na linha 6, após o título principal voll-med-api-erros, temos uma breve descrição do que faz o endpoint /specialists. Vamos substituir a descrição padrão por Service used to simulate an error in the request. Ou seja, um serviço utilizado para simular um erro em uma requisição.

# voll-med-api-erros

Service used to simulate an error in the request
COPIAR CÓDIGO
Portanto, a primeira etapa será a configuração do Apiary para simular um erro na resposta do servidor.

Na lateral direita, em "List All Questions", a ideia é substituir o endpoint que ele nos fornece e usar no nosso aplicativo. No dropdown de "Request", vamos trocar "Production" por "Mock Server" (servidor simulado). Com isso, o seguinte endpoint é fornecido:

https://private-854ce4-vollmedapierros.apiary-mock.com/specialists
COPIAR CÓDIGO
Conclusão
Para iniciar, queíamos configurar o Apiary com você, explicar o que exploraremos na primeira etapa deste curso. No próximo vídeo, vamos começar a trabalhar no projeto para entender como configurar o projeto para tratar esses casos de erro.

Até o próximo vídeo.

@@04
Tentativa e erro

Na Clínica Médica Voll (Medicina), você está trabalhando como dev front-end para melhorar a experiência do usuário no aplicativo da clínica. Você recebeu uma tarefa para simular e lidar com erros na requisição da API. Assim, quando um erro ocorre, o aplicativo não trava e dá feedback adequado ao usuário. Vamos supor que você recebeu um erro 400 ao tentar acessar a lista de médicos especialistas através do aplicativo.
Você já simulou esse erro. Como você lidaria com isso para que o aplicativo não travasse para o usuário?

Você criaria um bloco try-catch para tratar o erro.
 
Este é o método correto para lidar com erros em uma requisição. Ao lançar um novo erro com a mensagem de erro da resposta, estamos informando o usuário sobre o que aconteceu sem travar o aplicativo.
Alternativa correta
Você registraria o erro em uma variável e passaria para um try-catch, finalizando o aplicativo.
 
Alternativa correta
Você tentaria fazer a requisição via try-catch até ter uma resposta positiva.
 
Alternativa correta
Você deixaria o usuário tratar o erro com uma mensagem completa dele.

@@05
Faça como eu fiz: simulando e lidando com erros

A Clínica Médica Voll (Medicina) quer melhorar a comunicação com seus usuários através do seu aplicativo. Sua tarefa é ajudar a equipe de desenvolvimento identificando os erros de uma requisição e mostrar isso de forma clara para o usuário. Um exemplo de erro é quando um usuário tenta acessar a lista de médicos especialistas e recebe um erro 400. Você precisa simular este erro de exemplo e, em seguida, lidar com ele corretamente, exibindo uma mensagem adequada ao usuário ao invés de permitir que o aplicativo trave.

O código abaixo simula um erro 400 ao acessar a lista de médicos especialistas. A primeira parte do código é a simulação desse erro. Quando o usuário tenta acessar a lista de especialistas, em vez de receber as informações solicitadas, recebe um código de erro 400 com uma mensagem.
Para lidar com esse erro, substituímos o endereço da API em nosso aplicativo pelo endereço fornecido pelo nosso serviço de API mock.

Em seguida, tentamos buscar as informações da API. Se a resposta não estiver ok (ou seja, a resposta não tem um código de status na faixa de 200-299), obtemos a mensagem de erro da resposta e lançamos um novo erro com essa mensagem.

Se ocorrer um erro durante a operação de busca, capturamos esse erro em um bloco catch e registramos a mensagem do erro no console.

// Primeiro passo é simular o erro 400

{
  "error": {
    "code": 400,
    "message": "Ocorreu um erro, mas já estamos trabalhando para solucionar"
  }
}

// Substituir o endereço da API no seu aplicativo para simular o erro

let apiAddress = 'http://mock_api_address.com' // substituir esse endereço para o fornecido pelo seu API mock service

// Lidar com o erro

try {
  let response = await fetch(apiAddress)
  if (!response.ok) {
    let error = await response.json()
    throw new Error(`Erro ${error.code}: ${error.message}`)
  }
} catch (error) {
  console.error('Houve um problema com a sua requisição:', error.message);
}

@@06
O que aprendemos?

Nessa aula, você aprendeu como:
Introdução ao gerenciamento de erros: Aprendemos a importância de gerenciar erros no desenvolvimento de aplicativos para prevenir instabilidades e fornecer feedback aos usuários.
Uso do API para simular erros: Familiarizamo-nos com a ferramenta API, que pode ser usada para documentar APIs e simular respostas de uma API, incluindo erros.
Status codes de erro: Estudamos os status codes, códigos de três dígitos que o back-end devolve ao cliente para informar o que aconteceu em uma requisição. Por exemplo, os status codes da classe de 200 a 299 indicam sucesso, enquanto o 401 indica não autorização.

#### 26/04/2024

@02-Erros comuns

@@01
Projeto da aula anterior

Você pode revisar o seu código e acompanhar o passo a passo do desenvolvimento do nosso projeto e, se preferir, pode baixar o projeto da aula anterior.
Bons estudos!

https://github.com/alura-cursos/3367-swift-tratamento-de-erros/archive/refs/heads/main.zip

@@02
Trabalhando com endpoint de mock

Com o Apiary configurado, podemos utilizá-lo no nosso projeto. A ideia, na parte direita da tela, onde ele nos fornece o endpoint de mock que criamos no API, é que ele retorne, de fato, esse JSON que configuramos.
https://private-854ce4-vollmedapierros.apiary-mock.com/specialists
COPIAR CÓDIGO
Copiamos toda essa URL, abrir uma nova aba no navegador e colar no campo de endereço na parte superior. Teclamos "Enter" para buscar o endereço.

The resource you're looking for doesn't exist.
Please check the API documentation or have a look on available resources below.

Ele está informando que o recurso ainda não existe, então é importante salvar todas as alterações que fizermos. Voltando ao editor de código, selecionamos o botão "Save", localizado do lado superior direito. Atualizamos a página no navegador novamente.

{
    "error": {
        "code": 400,
        "message": "Ops! Ocorreu um erro, mas já estamos trabalhando para solucionar"
    }
}
COPIAR CÓDIGO
Note que ele já nos retorna o JSON que configuramos no API. É exatamente isso que o aplicativo vai ler na hora de acessar o endpoint de mock que criamos utilizando o API.

Agora podemos voltar ao projeto no Xcode.

Configurando a URL no projeto
Para conseguirmos configurar essa URL no nosso projeto, devemos abrir o arquivo HTTPClient.swift.

Do lado esquerdo do Xcode, temos a pasta Base, que está dentro de Networking, e abrimos o arquivo HTTPClient.swift .

Este arquivo contém a configuração dos endpoints que criamos no projeto. Para utilizar o que criamos na API, será necessário comentar todo esse bloco de código. Portanto, desde a linha 17 até a linha 21, vamos selecionar e apertar a tecla "Command + /" para comentar todas as linhas ao mesmo tempo.

HTTPClient.swift
// código omitido

extension HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type?) async -> Result<T?, RequestError> {
        
//        var urlComponents = URLComponents()
//        urlComponents.scheme = endpoint.scheme
//        urlComponents.host = endpoint.host
//        urlComponents.path = endpoint.path
//        urlComponents.port = 3000

       guard let url = urlComponents.url else {
          return .failure(.invalidURL)
      }

// código omitido
COPIAR CÓDIGO
Podemos criar uma URL fake de Apiary semelhante àquela que configuramos na plataforma do Apiary. Copiamos o nome dessa constante que criamos na linha 23 e na linha 25 vamos substituir esse urlComponents.url pela nova. Na verdade, como ela não é opcional, podemos até criar uma URL diferente. Não precisamos fazer essa verificação. Portanto, vamos voltar para como estava e comentamos da linha 25 à linha 27.

HTTPClient.swift
// código omitido
        
//        var urlComponents = URLComponents()
//        urlComponents.scheme = endpoint.scheme
//        urlComponents.host = endpoint.host
//        urlComponents.path = endpoint.path
//        urlComponents.port = 3000

        let urlApiary = URL "https://private-854ce4-vollmedapierros.apiary-mock.com/specialists"

//        guard let url = urlComponents.url else {
//            return .failure(.invalidURL)
//        }

// código omitido
COPIAR CÓDIGO
Vamos criar uma nova URL. Na linha 29, let url é igual a URL(). Vamos instanciar usando um inicializador com string. E passamos a URL. Copiamos a linha 23 e colamos na linha 29, onde podemos apagar a linha 23 (let urlApiary = URL "https://private-854ce4-vollmedapierros.apiary-mock.com/specialists").

HTTPClient.swift
// código omitido
        
//        var urlComponents = URLComponents()
//        urlComponents.scheme = endpoint.scheme
//        urlComponents.host = endpoint.host
//        urlComponents.path = endpoint.path
//        urlComponents.port = 3000

//        guard let url = urlComponents.url else {
//            return .failure(.invalidURL)
//        }

let url = URL(string: 
"https://private-854ce4-vollmedapierros.apiary-mock.com/specialists") 

// código omitido
COPIAR CÓDIGO
Agora, podemos retornar uma URL opcional. Como, por exemplo, se digitarmos "fsdafdsfsdfsa" não é uma URL. Então, não conseguiremos criar esse objeto. Por ser opcional, podemos utilizar um guard. E caso não consigamos, retornaremos uma falha usando o else{}.

HTTPClient.swift
// código omitido
        
guard let url = URL(string: "https://private-854ce4-vollmedapierros.apiary-mock.com/specialists") else {
        return .failure(.invalidURL)
}

// código omitido
COPIAR CÓDIGO
Já temos uma URL para acessar o mock que criamos na API. Rodamos o aplicativo para testar, na parte superior esquerda, clicamos em "Run". E veremos o que acontece.

Ele está subindo o simulador do projeto e ao finalizar o carregamento, obtemos:

Skeleton da página inicial do aplicativo Vollmed. Na parte superior central há o ícone da Vollmed, abaixo o texto "Boas-vindas!" e na sequência o texto "Veja abaixo os especialistas da Vollmed disponíveis e marque já a sua consulta!".

Isso é importante para também pensarmos nos caminhos alternativos do nosso projeto. Quando ele consegue recuperar os especialistas disponíveis é exibido uma lista e o aplicativo fica conforme o esperado

Porém, quando ele não consegue obter essas informações, fica uma tela branca abaixo da mensagem "Veja abaixo os especialistas de "Vollmed" disponíveis e marque sua consulta". Mas a pessoa usuária tentará visualizar e não terá sucesso, então devemos também pensar nos caminhos alternativos.

Nesse caso, estamos simulando um erro 400. Para tratarmos desse erro, vamos abrir novamente o arquivo onde estamos mapeando o erro. Temos o enum de erro, no arquivo RequestError .

RequestError
// código omitido

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unknown

// código omitido
COPIAR CÓDIGO
E no arquivo HTTPClient.swift , temos o switch case, onde estamos tratando o erro de acordo com o statusCode, na linha 46.

Criando um case para o erro 400
A ideia é criar um novo case para a classe de erro 400. Então, na linha 59, temos esse retorno do sucesso. Vamos inserir um novo código e digitamos o caso de erro 400. Se der erro 400, vamos fazer alguma coisa com esse erro.

Primeiro, precisamos tentar recuperar a mensagem de erro que o servidor devolve. Para tal, criamos uma constante chamada errorResponse.

Voltando ao navegador onde obtivemos o JSON, precisamos conseguir acessar a mensagem que o servidor nos devolve de alguma forma, e conseguimos fazer isso fazendo a decodificação da resposta.

Ops! Ocorreu um erro, mas já estamos trabalhando para solucionar
Voltamos ao Xcode.

Para acessarmos essa mensagem, usamos o JSONSerialization, que é uma try function, então precisamos usar try?.

Na linha 59, chamamos JSONSerialization.jsonObject() passando o data, que são os dados que o servidor nos devolve. Converteremos isso para um dicionário de [string:Any], ou seja, a chave do dicionário é uma string e o valor não tem um tipo definido.

Para visualizarmos no console, vamos usar um print() de errorResponse. Por enquanto, vamos retornar um caso de falha, mas vamos alterar isso depois. Vamos usar invalidURL para conseguir buildar o projeto.

HTTPClient.swift
// código omitido

case 400:
let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
print(errorResponse)

return.failure(.invalidURL)

// código omitido
COPIAR CÓDIGO
Vamos colocar um breakpoint, ou seja, um aviso que colocamos no código para a execução parar em determinado ponto, para que possamos inspecionar o valor da nossa variável. Na linha 59, clicamos acima do número "59" do lado esquerdo. Observem que agora temos uma flecha na cor roxa acima do número, indicando que o código será interrompido nesse ponto.

Compilamos o projeto novamente clicando no botão de play na parte superior esquerda para visualizarmos se conseguiremos ler a mensagem de erro ou não.

Quando a linha fica verde, significa que o código está parado nesse ponto onde configuramos. Na parte inferior direita, digitamos uma linha de comando para conseguirmos ler o valor desse erro, mas ele precisa passar por essa linha primeiro.

No canto inferior esquerdo, selecionamos o segundo ícone de step over (uma base com uma seta acima). Do lado direito, digitamos po print(errorResponse).

Por algum motivo, ele não está deixando imprimir o valor, mas como colocamos um print na linha 60, faremos um step over e podemos visualizar se ele exibe o valor ali.

Obtemos:

Optional (["error": { 
code = 400;
message = "Ops! Ocorreu um erro, mas já estamos trabalhando para solucionar"; }])
COPIAR CÓDIGO
Do lado direito é exibido o error, o status code que é o 400, e a mensagem, que é exatamente o que configuramos aqui no API. Então, estamos conseguindo capturar essas informações no nosso aplicativo, exatamente isso que estamos lendo.

Como fazemos para continuar a execução do programa? Seguramos a linha 59 e arrastamos para fora e clicamos em continuar a execução do programa no primeiro ícone no canto inferior esquerdo.

Conclusão e Próximos Passos
Então o objetivo desse vídeo foi usarmos o mock que criamos no API para conseguirmos capturar a mensagem de erro. Agora nós temos um material, que é essa mensagem de erro, para informar ao usuário o que está acontecendo em nosso aplicativo.

Vamos continuar com isso a seguir!

@@03
Criando e tratando errors personalizados

Agora que já estamos conseguindo capturar o erro que configuramos no Apiary, é hora de começarmos a pensar em como podemos mostrar isso para a pessoa usuária. Até o momento, estávamos colocando alguns prints no código, apenas para verificar se conseguimos capturar o erro, mas a ideia é mostrarmos isso para a pessoa usuária.
Temos algumas abordagens: podemos utilizar um alert controller nativo do próprio iOS, podemos criar uma view personalizada e há várias formas de tratarmos esse erro.

Vamos criar uma view personalizada, que chamamos de snackbar, que é uma view temporária que serve para informar a pessoa usuária sobre algo no aplicativo. Pode ser mensagem de erro, mensagem de alerta ou até mesmo de sucesso. Existem vários tipos de feedback que podemos dar para a pessoa usuária.

Em nosso caso, estamos nos referindo especificamente de mensagem de erro, então a ideia desse snackbar é muito interessante porque não é uma view que aparece de forma intrusiva na tela, ou seja, não bloqueia a interação da pessoa usuária, é mais um aviso de algo que está acontecendo no app.

Configurando o erro
Agora temos um erro personalizável. Quando digo erro personalizável, por exemplo, nós vamos voltar no arquivo requestError, onde até então tínhamos erros pré-definidos e sabíamos exatamente o que aconteceu porque criamos um caso para cada erro.

requestError
import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unknown
    case custom(error: [String: Any]?)
    
    var customMessage: String {
        switch self {
        case .decode:
            return "erro de decodificação"
        case .unauthorized:
            return "sessão expirada"
        default:
            return "erro desconhecido"
        }
    }
}
COPIAR CÓDIGO
Como o servidor, nesse caso, pode devolver o tipo de erro que ocorreu em uma requisição, a ideia é criar um case de erro custom. Ou seja, podemos receber por parâmetro uma mensagem e assim conseguimos manipular essa mensagem como quisermos.

Criaremos um novo case chamado de custom() passando como parâmetro o erro, que é um dicionário de String opcional, ?. Assim temos o novo case de erro.

RequestError.swift
import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unknown
    case custom(error: [String: Any]?)
    
    var customMessage: String {
        switch self {
        case .decode:
            return "erro de decodificação"
        case .unauthorized:
            return "sessão expirada"
        default:
            return "erro desconhecido"
        }
    }
}
COPIAR CÓDIGO
No arquivo HTTPClient, tínhamos configurado na linha 62 um retorno de falha qualquer, só para o aplicativo buildar, e agora já conseguimos utilizar o novo case que temos, que é o custom.

Apagamos o invalidURL da linha 62 e vamos usar o custom. No erro vamos passar o que criamos aqui na linha 59, esse errorResponse, então copiamos com "Ctrl + C", e colamos, e esse print da linha 60 nós não vamos mais utilizar, então nós vamos apagar.

HTTPClient.swift
// código omitido

case 400:
let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
return.failure(.custom(error: errorResponse))

// código omitido
COPIAR CÓDIGO
Isso é um caso clássico de erro 400, mas poderíamos fazer isso para tratar qualquer outro tipo de erro, isso depende do acordo que o time tiver com o back-end, com o time de produto, de UX, sobre como é feito o tratamento de erro no projeto.

Estamos dando o exemplo do caso de erro 400, mas poderia ser utilizado para tratar vários outros erros que vêm do back-end. Então lembrando, esse errorResponse do arquivo HTTPClient vamos utilizar no Apiary para capturar esse JSON, que tem a mensagem "Ops, ocorreu um erro, mas já estamos trabalhando para solucioná-lo".

Vamos salvar mais uma vez, corrigimos a mensagem de erro, e essa é a ideia então do case que criamos customizado. Quando retornamos na linha 60 do arquivo HTTPClient, ele vai retornar esse erro para quem fez a requisição.

Quem fez a requisição está dentro do arquivo HomeViewModel. No menu lateral esquerdo vamos abrir o arquivo HomeViewModel , e temos o método getSpecialists(), onde temos o caso de sucesso na linha 31 e o de falha, o de erro, na linha 33.

HomeViewModel.swift
    func getSpecialists() async throws -> [Specialist]? {
        let result = try await service.getAllSpecialists()
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
COPIAR CÓDIGO
Nesse caso, como estamos forçando um erro através da Apiary, a ideia é que ele lance a exceção do erro. Só para testar, na linha 33 vamos colocar um print() desse erro, e colocar mais uma vez um breakpoint clicando em cima da linha 34.

Então nós clicamos no número "34" do lado esquerdo da linha, quando o aplicativo passa por essa linha ele para, e conseguimos visualizar qual é o erro.

HomeViewModel.swift
    func getSpecialists() async throws -> [Specialist]? {
        let result = try await service.getAllSpecialists()
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            print(error)
            throw error
        }
    }
COPIAR CÓDIGO
Vamos rodar o projeto mais uma vez para testar e ver se está caindo no ViewModel no caso de erro. O aplicativo parou na linha 34, porque mostra nessa linha verde. Clicamos no step over para ele passar para a linha de baixo.

Do lado inferior direito, obtemos a mensagem:

Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo!
Ele já imprime a mensagem de erro corretamente.

Vamos remover o breakpoint, clicando e arrastando para fora, e vamos clicar em continuar a execução do programa. Colocamos o print na linha 34 só para testar e podemos removê-lo; já estamos recebendo o erro, a exceção no método getSpecialists().

Conclusão e Próximos Passos
Com isso, a primeira parte, que é a configuração do erro, já está feita. Agora vamos começar a trabalhar na view do snackbar. Então vamos ver isso no próximo vídeo.

@@04
Criando uma View personalizada para erros

Continuando, agora é hora de criarmos nossa view customizada, que se chamará SnackBarErrorView.swift. Dentro da pasta view no diretório principal do nosso projeto, temos várias views.
Views
Components
HomeView
Schedule AppointmentView
MyAppointmentsView
CancelAppointmentView
SignInView
SignUpView
Selecionamos com o botão direito em Views, clicamos em novo grupo e colocamos o nome da pasta de SnackBarView. Dentro dela, vamos criar um novo arquivo; botão direito, novo arquivo, escolhemos aqui SwiftUI View e clicar em "Next". O nome do arquivo será SnackBarErrorView e clicamos em "Create".

SnackBarView
SnackBarErrorView
SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {
var body: some View {
Text("Hello, World!")
}
}
#Preview {
SnackBarErrorView()
}
COPIAR CÓDIGO
Quando criamos um arquivo usando o SwiftUI, temos também a área de pré-visualização. No meu caso, ela veio oculta. Então, se desejarmos exibir, teclamos "Command Option + Enter". Isso abre uma tela do lado direito.

É gerado um arquivo padrão do SwiftUI quando criamos uma nova view e a ideia é começarmos a criar o snackbar. O que vamos começar desenvolvendo? Apagamos o texto e criamos um vertical stack view, ou seja, um VStack.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {
var body: some View {
VStack {
}
}
}
#Preview {
SnackBarErrorView()
}
COPIAR CÓDIGO
Dentro do VStack, faremos algumas verificações. Primeiro, vamos verificar se o snackbar é visível; então, vamos precisar de uma variável de controle para exibir ou não o snackbar. Na linha 10, onde temos a declaração da view, teclamos "Enter" e criamos, na linha 12, uma nova variável.

Será var isShowing: Bool, para representar nossa variável booleana. São variáveis booleanas, podem ser visíveis ou não, então são true ou false. Além disso, elas têm uma característica a mais que vamos inserir, sendo o Binding.

O @Binding é usado como variável de controle e, quando houver a troca de valor desse isShowing, a view será recarregada e poderemos mostrar ou ocultar o snackbar.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool

var body: some View {
VStack {
}
}
}
#Preview {
SnackBarErrorView()
}
COPIAR CÓDIGO
Quando adicionamos um novo parâmetro na view, e mencionamos uma struct, temos que mexer na inicialização; por isso que está apontando um erro na linha 22, e precisamos passar um valor para esse parâmetro isShowing.

Como é Binding, vamos utilizar .constant e passar um valor fixo, que no caso será true. Como estamos desenvolvendo a view, desejamos visualizá-la na tela do lado direito.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool

var body: some View {
VStack {
}
}
}
#Preview {
SnackBarErrorView(isShowing: .constant(true))
}
COPIAR CÓDIGO
Dentro do VStack na linha 15, inserimos um if para verificar se o valor da variável isShowing é true. Se for, vamos começar criando nosso snackbar. Primeiro, vamos criar um Text(), que mostrará uma mensagem chamada message. Ainda não criamos essa variável, então teremos um erro, pois message não existe.

Assim, logo após a linha 12, onde criamos a variável de controle isShowing, na linha 13, criamos uma variável chamada message, que será do tipo String, pois vai armazenar texto.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool
var message: String

var body: some View {
VStack {
if isShowing {
Text(message)
}
}
}
}
#Preview {
SnackBarErrorView(isShowing: .constant(true))
}
COPIAR CÓDIGO
Depois do texto que criamos, na linha 18, inserimos algumas configurações. Colocamos, por exemplo, .padding(), vamos adicionar uma cor de fundo, então .background(Color.red), já que estamos mostrando uma mensagem de erro, é comum que seja vermelha.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool
var message: String

var body: some View {
VStack {
if isShowing {
Text(message)
.padding()
.background(Color.red)
}
}
}
}
#Preview {
SnackBarErrorView(isShowing: .constant(true))
}
COPIAR CÓDIGO
Na área de pré-visualização na última linha do arquivo ainda está reclamando porque adicionamos um novo parâmetro, que é o message, na linha 13, então precisamos definir um texto. Vamos utilizar o mesmo texto que temos na Apiary.

Voltamos ao Chrome, selecionamos a mensagem de erro na linha 17 do Apiary com "Command + C" ou "Ctrl + C", voltamos ao Xcode e definimos essa mensagem como uma String.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool
var message: String

var body: some View {
VStack {
if isShowing {
Text(message)
.padding()
.background(Color.red)
}
}
}
}
#Preview {
    SnackBarErrorView(isShowing: .constant(true), message: "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo")
}
COPIAR CÓDIGO
Na pré-visualização, como podem visualizar, estamos começando a criar o snackbar, temos uma mensagem de erro envolta de um retângulo vermelho.

Pré-visualização do aplicativo Vollmed. Na parte central há a mensagem "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo" escrito na cor preta e dentro de um retângulo preenchido na cor vermelha.

Vamos continuar a implementação.

O texto seria interessante deixarmos em branco, então vamos alterar a cor do texto com .foregroundColor(.white) e também vamos arredondar o canto desse retângulo vermelho que temos na mensagem de erro, que no caso é o fundo do texto, com .cornerRadius(10).

Assim, eles ficam arredondados com uma estética, uma aparência um pouco melhor para uma mensagem de erro.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool
var message: String

var body: some View {
VStack {
if isShowing {
Text(message)
.padding()
.background(Color.red)
.foregroundColor(.white)
.cornerRadius(10)
}
}
}
}
#Preview {
    SnackBarErrorView(isShowing: .constant(true), message: "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo")
}
COPIAR CÓDIGO
Pré-visualização do aplicativo Vollmed. Na parte central há a mensagem "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo" escrito na cor branca e o retângulo agora possui as bordas arredondadas. 

Conclusão e Próximos Passos
Nossa ideia: começamos a criar nosso snackbar. Ainda tem bastante configuração que precisamos fazer nele, como definir por quantos segundos ele será visível na tela e qual é a região da tela que vamos mostrar; geralmente ele aparece de baixo para cima.

Mas a ideia desse vídeo foi, de fato, começar o desenvolvimento desse snackbar. A seguir, continuamos!

@@05
Implementando a SnackBar na home

Continuando, agora que já criamos a View do SnackBar, vamos fazer os últimos ajustes e depois integrá-la com nosso projeto, na HomeView. A ideia do SnackBar é exibir na parte inferior de uma forma mais sutil, ao invés de exibi-lo no meio da tela.
Ajustando o SnackBar
SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool
var message: String

var body: some View {
VStack {
if isShowing {
Text(message)
.padding()
.background(Color.red)
.foregroundColor(.white)
.cornerRadius(10)
}
}
}
}
#Preview {
    SnackBarErrorView(isShowing: .constant(true), message: "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo")
}
COPIAR CÓDIGO
Para isso, vamos adicionar um Spacer() logo abaixo do VStack. Na linha 16, onde temos o VStack, pressionamos a tecla "Enter" e incluímos um Spacer(). O Spacer é um elemento de espaçamento que preenche todo o espaço disponível, empurrando os elementos para baixo.

SnackBarErrorView
import SwiftUI

struct SnackBarErrorView: View {

@Binding var isShowing: Bool
var message: String

var body: some View {
VStack {
Spacer()
if isShowing {
Text(message)
.padding()
.background(Color.red)
.foregroundColor(.white)
.cornerRadius(10)
}
}
}
}
#Preview {
    SnackBarErrorView(isShowing: .constant(true), message: "Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo")
}
COPIAR CÓDIGO
Observem que agora o retângulo com a mensagem de erro está na parte inferior do aplicativo do lado direito na pré-visualização.

No arquivo HomeView (tela principal), ocultamos a pré-visualização com" Command Option + Enter". A primeira coisa que fazemos é criar uma variável de controle para determinar se exibiremos o SnackBar ou não, com base no erro da requisição.

Na linha 16, após listar os especialistas, criamos a variável usando @State private var IsShowingSnackBar, inicializada com false, pois não queremos exibir o SnackBar ao abrir o aplicativo, apenas quando ocorrer um erro.

HomeView.swift
// código omitido

@State private var specialists: [Specialist] = []
@State private var isShowingSnackBar = false

// código omitido
COPIAR CÓDIGO
Quando vamos mudar o valor dessa variável? Na chamada para o GetSpecialists() na parte central do código (linha 48), quando ocorrer um erro, o IsShowingSnackBar será igual a true. Na linha 51, não estamos tratando o caso de erro e sim apenas printamos o erro.

Portanto, iremos começar a trabalhar com o catch(). Primeiro, iremos alterar o valor da variável nesse trecho de código. Digitamos isShowingSnackBar = true, ao entrar no catch().

HomeView.swift
// código omitido

Task {
do {
guard let response = try await viewModel.getSpecialists() else { return }
self.specialists = response
} catch {
isShowingSnackBar = true
}
}

// código omitido
COPIAR CÓDIGO
Quando instanciamos o SnackBar, precisamos de uma mensagem de erro, que geralmente vem do servidor. Por isso, criamos outra variável, @State private var errorMessage, inicializada com uma string vazia, = "".

HomeView.swift
// código omitido

@State private var specialists: [Specialist] = []
@State private var isShowingSnackBar = false
@State private var errorMessage = ""

// código omitido
COPIAR CÓDIGO
O que faremos com o errorMessage? Logo abaixo de onde alteramos o valor da variável boolean isShowingSnackBar = true iremos procurar e extrair o valor do erro para preenchermos a variável criada.

Criamos uma constante chamada errorType que será igual ao erro que estamos recebendo no catch(). A exceção é lançada e conseguimos capturar aqui. Convertemos para o Enum de erro que temos, sendo o RequestError.

Atribuímos ao errorMessage o valor errorType?.customMessage ??. Se não houver mensagem opcional, usaremos a mensagem padrão "Ops! ocorreu um erro".

HomeView.swift
// código omitido

Task {
do {
guard let response = try await viewModel.getSpecialists() else { return }
self.specialists = response
} catch {
isShowingSnackBar = true
let errorType = error as? RequestError
errorMessage = errorType?.customMessage ?? "Ops! Ocorreu um erro"
}
}
}

// código omitido
COPIAR CÓDIGO
Agora de fato chamaremos nosso SnackBar. Abaixo da toolbar, fazemos uma verificação com um if(), checando a variável booleana. Se verdadeira, instanciamos o SnackBarErrorView, passando o valor de IsShowingSnackBar e errorMessage.

HomeView.swift
// código omitido

if isShowingSnackBar {
SnackBarErrorView(isShowing: $isShowingSnackBar, message: errorMessage)
}

// código omitido
COPIAR CÓDIGO
Para testar, subimos o simulador e verificamos a mensagem de erro configurada.

Página inicial do aplicativo Vollmed. Na parte superior central há o ícone da Vollmed, abaixo o texto "Boas-vindas!" e na sequência o texto "Veja abaixo os especialistas da Vollmed disponíveis e marque já a sua consulta!". Na parte inferior há um retângulo vermelho com o texto "Erro desconhecido" na cor branca.

O último ajuste é garantir que o SnackBar apareça acima de qualquer elemento, e não abaixo do último. A ideia do SnackBar é exibir as informações acima de qualquer elemento. Para isso, substituímos o elemento relevante por um ZStack. Assim, ele estará correto na posição inferior da aplicação.

Selecionamos o ScrollView e todo o seu conteúdo desde a linha 21 até onde instanciamos o SnackBar, cortamos com "Command + X". Então, adicionamos o ZStack, colando dentro dele tudo o que foi copiado com "Command + V".

HomeView.swift
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .padding(.vertical, 32)
                    Text("Boas-vindas!")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color(.lightBlue))
                    Text("Veja abaixo os especialistas da Vollmed disponíveis e marque já a sua consulta!")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.accentColor)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    ForEach(specialists) { specialist in
                        SpecialistCardView(specialist: specialist)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .onAppear {
                Task {
                    do {
                        guard let response = try await viewModel.getSpecialists() else { return }
                        self.specialists = response
                    } catch {
                        isShowingSnackBar = true
                        let errorType = error as? RequestError
                        errorMessage = errorType?.customMessage ?? "Ops! Ocorreu um erro"
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.logout()
                        }
                    }, label: {
                        HStack(spacing: 2) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                    })
                }
            }
            if isShowingSnackBar {
                SnackBarErrorView(isShowing: $isShowingSnackBar, message: errorMessage)
            }
COPIAR CÓDIGO
Rodamos o projeto para confirmar que está tudo certo, compilamos com Build, e a mensagem de erro deve aparecer corretamente.

A seguir, continuaremos fazendo uma alteração no enum RequestError, para mostrar a mensagem de erro que vem do mock que criamos no Apiary.

@@06
ZStack com SnackBar

Analise o trecho de código a seguir, que tenta colocar uma mensagem de erro na barra superior do aplicativo.
ZStack {
    NavigationView {
        VStack {
            // Bloco 1
        }.navigationBarTitle("Erro")
    }
    // Bloco 2
}
COPIAR CÓDIGO
Onde seria o local correto para a chamada da Snackbar?

No lugar do comentário // Bloco 2
 
O ZStack permite o empilhamento de elementos, então colocar a chamada ao Snackbar neste local permite que a mensagem de erro seja exibida acima da NavigationView.
Alternativa correta
No lugar do comentário // Bloco 1
 
Colocar a chamada ao Snackbar antes do título do NavigationBar apresentará a mensagem de erro abaixo da barra de título. Não é exatamente o que queremos para esse cenário.
Alternativa correta
Logo depois de ZStack {
 
Alternativa correta
Logo após NavigationView {

@@07
Faça como eu fiz: tratando erros com mocks

Você é uma pessoa desenvolvedora trabalhando no aplicativo da Clínica Médica Voll. No entanto, nem sempre tudo funciona de acordo com o planejado. O usuário pode estar sem internet, o servidor pode estar caído, a requisição do servidor pode falhar. Devemos informar ao usuário os erros que possam ocorrer. No código base fornecido, foi implementada uma maneira de tratar erros do tipo 401 (não autorizado), porém ainda há necessidade de tratar outros erros que possam ocorrer, assim como, criar uma maneira de informar esses erros ao usuário.

Para isso, modifique o código base para que ele possa tratar erros do tipo 400 (solicitação inválida) e 500 (erro interno do servidor), retornando a falha correspondente. Em seguida, crie uma função que exiba uma barra de erro com uma mensagem para o usuário, informando que algo deu errado.
extension HTTPClient {
    func sendRequest<T: Decodable>(endpoint: Endpoint, responseModel: T.Type?) async -> Result<T?, RequestError> {

        guard let url = URL(string: "https://private-854ce4-vollmedapierros.apiary-mock.com/specialists") else {
            return .failure(.invalidURL)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }

            switch httpResponse.statusCode {
            case 200..<300:
                let decodedResponse = try? JSONDecoder().decode(T.self, from: data)

                return .success(decodedResponse)
            case 400:
                return .failure(.invalidRequest)
            case 500:
                return .failure(.internalServerError)
            case 401:
                return .failure(.unauthorized)

            default:
                return .failure(.unknown)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}
COPIAR CÓDIGO
O código acima trata 3 tipos de erros HTTP que são comuns em aplicativos: 400 (pedido inválido), 401 (não autorizado) e 500 (erro interno do servidor). Para cada um desses erros, a função sendRequest retorna um valor de falha apropriado. Além disso, para outros códigos de status não reconhecidos, ele retornará unkown (desconhecido).

@@08
O que aprendemos?

Nessa aula, você aprendeu como:
Configurando o API: Aprendemos como configurar a API em nosso projeto e como utilizar o endpoint de mock criado.
Utilizando o HTTP Client: Este vídeo nos ensinou a configurar adeptamente a URL para nosso projeto no arquivo HTTP Client.
Tratando erros: Aprendemos a tratar erros com o status code usando um switch case e a criar um caso de erro específico para a classe de erro 400.
Erro customizável: Aprendemos a criar um caso de erro customizado, que permite a manipulação mais flexível da mensagem de erro.
Decodificando a resposta: Foi explicado como usar o JSON Serialization para decodificar a resposta do servidor e converter esta resposta para um dicionário.
Uso de ZStack: Aprendemos também como usar o ZStack para colocar elementos um acima do outro. Isso é importante para casos em que o Snackbar deve ser exibido acima de outros elementos.