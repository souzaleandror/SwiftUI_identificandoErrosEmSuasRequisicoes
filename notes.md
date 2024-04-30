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

#### 28/04/2024

@03-Finalizando SnackBar

@@01
Projeto da aula anterior

Você pode revisar o seu código e acompanhar o passo a passo do desenvolvimento do nosso projeto e, se preferir, pode baixar o projeto da aula anterior.
Bons estudos!

https://github.com/alura-cursos/3367-swift-tratamento-de-erros/archive/refs/heads/aula-2.zip

@@02
Mostrando o erro no SnackBar

O objetivo desta aula é finalizarmos o snackbar.
Ainda tem alguns comportamentos que precisamos terminar, como, por exemplo, mostrar o snackbar por alguns segundos e depois ocultar. Além disso, há a necessidade de ajustar a parte da mensagem de erro, que está sendo exibida como erro desconhecido. Vamos fazer alguns ajustes no nosso enum de erros.

Começaremos inserindo a mensagem que foi configurada no backend. Vou abrir a pasta Networking, nela temos o RequestError, que é o enum de erro que criamos. Temos um caso de erro já configurado e a ideia agora é implementar este caso para retornar a mensagem que vem do backend.

Logo abaixo da linha 23, criarei um novo caso, chamado custom. Vou capturar o erro criando uma constante chamada errorData. A ideia é extrair o valor do erro. Para evitar que o compilador aponte uma mensagem de erro, retornarei uma string vazia e em depois podemos apagá-la.

Na linha 26, começarei criando um if let chamado jsonError. Este será igual à constante errorData criada na linha 24. Tentarei acessar o objeto erro (error), e convertê-lo para um dicionário de String n ([String: Any]).

Dentro do if let, criarei uma constante chamada message. Acessarei a mensagem através da constante errorData (é opcional, então vou colocar ? após errorData).

Dentro do if, vamos criar o message igual ao jsonError e acessarei o valor da mensagem, jsonError["message"]. Tentarei converter isso para uma string. Caso não consiga, para evitar a opção nula, colocarei uma string vazia. Agora que temos a mensagem, posso retornar a message.

    var customMessage: String {
        switch self {
        case .decode:
            return "erro de decodificação"
        case .unauthorized:
            return "sessão expirada"
        case .custom(let errorData):
            if let jsonError = errorData?["error"] as? [String: Any] {
                let message = jsonError["message"] as? String ?? ""
                return message
            }
COPIAR CÓDIGO
Se por acaso não entrar neste if, ou seja, ocorrer algum problema no objeto que o servidor está retornando, deixarei um erro pré-configurado. Algo como "Ops, ocorreu um erro ao carregar as informações".

    var customMessage: String {
        switch self {
        case .decode:
            return "erro de decodificação"
        case .unauthorized:
            return "sessão expirada"
        case .custom(let errorData):
            if let jsonError = errorData?["error"] as? [String: Any] {
                let message = jsonError["message"] as? String ?? ""
                return message
            }
            return "Ops! Ocorreu um erro ao carregar as informações"
        default:
            return "erro desconhecido"
        }
COPIAR CÓDIGO
Com isso concluímos a configuração do caso do custom. Vou voltar ao arquivo HomeView, onde temos a nossa implementação. Vamos rodar o projeto para testar.

Cliquei em "Run" na parte superior esquerda. Ele exibe exatamente o erro que estamos recebendo da API que criamos. Esta mensagem:

Ops! Ocorreu um erro, mas já estamos trabalhando para solucioná-lo
Para confirmar se está funcionando mesmo, vamos abrir a API e alterar a mensagem de erro.

Vamos inserir uma nova mensagem que será: "Erro ao carregar os especialistas".

Sempre que fazemos uma alteração na API, precisamos salvar. Na parte superior direita temos o botão "Save".

Ao rodar o projeto mais uma vez, notamos que a mensagem de erro que configuramos na API foi alterada. Agora está exibindo a seguinte mensagem:

Erro ao carregar os especialistas
Isso significa que estamos conseguindo capturar o erro que o servidor está nos retornando e mostrar no app. O mais importante é isso: manter o usuário atualizado sobre o que está acontecendo no aplicativo.

A ideia principal dessas aulas é sempre dar esse feedback para o usuário, para que ele perceba as ações do app.

Voltarei à API. Alterei a mensagem de erro na linha 17 somente para testar. Vou retornar à mensagem que estava antes e salvar.

Ao rodar mais uma vez o projeto, temos o snackbar com a mensagem correta. A ideia agora é terminarmos de configurar com alguns ajustes. Note que o snackbar ficou muito próximo à tab bar. Portanto, a ideia é dar um espaçamento maior e aplicar um efeito para que ele desapareça de acordo com os segundos que configurarmos. Veremos isso a seguir!

@@03
Finalizando a View da SnackBar

Estamos de volta com o nosso projeto. Então, a ideia é finalizarmos o nosso snackbar. A primeira coisa que vamos trabalhar neste vídeo é para fazer o snackbar desaparecer após um determinado tempo. Então, vamos configurar alguns segundos e, depois disso, fazer o snackbar desaparecer.
Para isso, vamos abrir a view do snackbar. No menu lateral esquerdo, vamos acessar o arquivo Views/SnackBarView /SnackBarErrorView. É onde temos toda a implementação da view que criamos.

Vamos utilizar um método chamado DispatchQueue, que permite configurar determinados segundos e alterar para a thread principal, que é a thread que utilizamos para fazer modificações da interface do usuário. Com base nisso, conseguimos fazer nosso snackbar desaparecer.

Na linha 24, abaixo do .cornerRadius(10), vamos colocar um método chamado onAppear. Esse método serve para colocar tudo que queremos que uma view faça assim que ela seja desenhada na tela. Então, nesse caso, queremos mostrar o snackbar e, depois de um determinado tempo, fazer ele desaparecer.

No onAppear, podemos chamar o método dispatchQueue.main.after. Quando colocamos .after, ele traz no autocomplete vários inicializadores para esse método. O que vamos utilizar é o primeiro, que está sendo mostrado, o asyncAfter(deadline:execute) que permite passar um tempo e, depois, a execução.

Esse deadline é a configuração dos segundos que vamos utilizar. Quero que comece no momento que ele seja exibido, portanto .now mais 3 segundos. Quero que ele dure 3 segundos. O segundo parâmetro execute, vamos apagar. Depois disso, vamos configurar para remover o snackbar.

Vamos utilizar essa variável que criamos com o binding, que é esse isShowing, e vamos configurar o valor como false.

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Text(message)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isShowing = false
                        }
                    }
            }
        }
COPIAR CÓDIGO
Relembrando, inicializamos fazendo uma verificação. Se isShowing for verdadeiro, ele desenha nosso componente snackbar. Se for falso, ele não faz nada. Então, a ideia é alterar o valor dela no isShowing. Vou fazer isso de forma animada, então, vamos utilizar o método ifAnimation, onde posso colocar o isShowing. Vou recortar e colocá-lo aqui dentro. Alterei para false.

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Text(message)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
COPIAR CÓDIGO
Vamos rodar o projeto para ver se está funcionando. Vou gerar um build e clicar em "Run". Ele subiu o simulador, mostrou o snackbar de erro, e depois de 3 segundos ele desapareceu.

Refinando o componente
Até aqui, já conseguimos uma grande evolução, que é mostrar e fazer o snackbar desaparecer. Agora, vamos refinar o nosso componente, adicionando algumas animações. A primeira que vamos inserir é uma transição no snackbar. Então, ele vai aparecer na tela e, depois de 3 segundos, quero que ele faça um efeito como se estivesse sendo removido de cima para baixo.

Vamos implementar um método de transição, Transition, antes do onAppear. Na transição, consigo colocar uma opção chamada move e posso configurar para onde eu quero que ele vá. No nosso caso, para a parte inferior, que é o bottom.

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Text(message)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
COPIAR CÓDIGO
Com isso, já temos o efeito da transição. Vou rodar o projeto mais uma vez. Então, ele vai mostrar o snackbar e, depois de um tempo, ele vai descer com a mensagem.

Para finalizar, vamos ajustar o espaçamento entre o snackbar e as opções abaixo da TabBar.. Vou fazer isso depois de terminar o VStack. Então, tenho aqui a chave onde fecho o VStack e é aqui que vamos implementar.

Vou colocar um frame. Esse frame quero que pegue a altura máxima disponível. Então, vamos utilizar o parâmetro MaxWidth, onde vamos passar infinity. Assim, ele pega toda a largura disponível dentro da tela que estou exibindo o componente.

Depois disso, coloco um Padding na horizontal. Lembrando, o Padding na horizontal pega a horizontal e adiciona um pouco de Padding de cada lado. Então, é isso que faço nessa linha. Se eu quisesse colocar o Padding de um lado só, teria que apontar se é Leading ou Trailing, ou seja, se é esquerda ou direita. O eixo que eu quero pegar para colocar o Padding.

Nesse caso, como coloquei horizontal, ele vai pegar um pouco dos dois lados. Para finalizar, vamos colocar Padding na parte inferior. Então, pego aqui o Bottom e faço uma verificação. Se eu estou exibindo, ou seja, se isShowing é verdadeiro.

Aqui utilizarei uma extensão que deixarei disponível para você copiar antes de iniciar essa aula. Ela está no material do curso. Portanto, vamos pedir para você adicioná-la no projeto.

Vou fazer um zoom aqui perto da pasta onde tenho as Extensions. Então, dentro da pasta Extensions vamos criar o arquivo UIApplication+. O código desse arquivo, vamos deixar disponível para você copiar e utilizar em seu projeto:

UIApplication+
//  UIAplication+.swift
//  Vollmed
//
//  Created by ALURA
//

import UIKit

extension UIApplication {
    var getKeyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}
COPIAR CÓDIGO
Esse código, basicamente, pega a Window, que é a tela ativa. Para conseguirmos colocar o Bottom que eu preciso no snackbar, precisamos verificar qual é a janela ativa para conseguir fazer isso.

Então, tem aqui uma extensão onde verifica isso, qual é a janela ativa. A partir disso, conseguimos pegar a SafeAreaInsets, como chamamos, para pegar de fato o Bottom.

Então, veja como funciona. Na linha 36 vamos utilizar o UIApplication. É um Singleton, então .share.getKeyWindow, que é a extensão que comentei com você. Que está aqui na linha 11, var getKeyWindow: UIWindow?.

Com isso pego a SafeArea, que é o espaço que temos dos iPhones, tanto na parte inferior quanto superior. E quero pegar a parte de baixo, então .bottom. Se ele não conseguir, pego aqui e configuro um valor de 0.

Caso contrário, quero que meu snackbar fique um tamanho de 100 acima da parte inferior que peguei. Ou seja, fica com uma margem um pouco mais agradável para o nosso componente.

 .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom, isShowing ? UIApplication.shared.getKeyWindow?.safeAreaInsets.bottom ?? 0 : -100)
COPIAR CÓDIGO
Então, o que é importante aqui é que estamos utilizando uma extensão, que estará disponível para você utilizar e adicionar no seu projeto. E também ajustamos a questão da exibição ou não do snackbar.

Vamos rodar o projeto para ver se está tudo ok. Então, vamos gerar mais um build e aí vamos fazer esse teste.

Perceba que ficou com uma margem um pouco maior. E a animação de cima para baixo para desaparecer com o snackbar.

Com isso, terminamos de fato a implementação do snackbar.

Uma coisa que não podemos esquecer é de ir no arquivo HTTPClient, onde configuramos o apiary. Então, fizemos tudo isso através do apiary. Agora que já não precisamos mais dela, vamos apagar essa URL que criamos aqui, desde a linha 27 até a linha 29. E vamos utilizar a URL Components que já tínhamos. Esse trecho de código ficará assim:

        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path
        urlComponents.port = 3000
        
        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
//código omitido
COPIAR CÓDIGO
Então, é isso que vamos fazer, para voltarmos com a implementação do aplicativo. Vou rodar mais uma vez o app para testarmos e aí ele traz a lista de médicos especialistas.

Com isso, finalizamos essa aula sobre o snackbar, que serve para uma infinidade de coisas, principalmente para tratamento de erros, conforme vimos nas primeiras aulas!

@@04
Todos por um?

Durante a aula, analisamos o projeto VollMed desenvolvido até o momento. Percebemos que a classe WebService é responsável pela implementação de todos os métodos de requisição do aplicativo. Quais são possíveis problemas você poderia destacar ao colocar todos os métodos em uma única classe:

O arquivo pode ficar muito grande, o que implicaria na demora do tempo de resposta de uma requisição.
 
Alternativa correta
Concentrar todas as requisições no mesmo arquivo pode prejudicar a escalabilidade do projeto, e dificultaria o entendimento de quais requisições pertencem a quais funcionalidades do projeto.
 
Quando colocamos tudo em um único lugar, se torna muito mais complicado de encontrar e entender o que faz cada requisição no projeto.
Alternativa correta
A classe WebService, apesar de cuidar apenas de requisições http, pode se tornar um arquivo muito grande a medida que o projeto cresce. Ou seja, não é escalável.
 
Esse tipo de implementação pode crescer a medida que o projeto aumentar, o que acarretaria em problemas de manutenção.

@@05
Faça como eu fiz: alterando a SnackBar View

Na Clínica Médica Voll, a equipe de TI está trabalhando para melhorar a experiência do usuário em seu aplicativo. Eles perceberam que os usuários têm problemas ao receber mensagens de erro quando algo dá errado no aplicativo. Eles querem que sua mensagem de erro apareça na forma de uma snackbar, que deve desaparecer após 3 segundos. Ajude-os a implementar isso.
Você precisa modificar a View do snackbar para que ele desapareça depois de 3 segundos. Para fazer isso, você precisará fazer uso do modificador .onAppear para determinar quando a View aparece na tela. Depois disso, você deve agendar a execução de isShowing = false para depois de 3 segundos usando DispatchQueu.main.asyncAfter. Por último, você deve adicionar um bloco de animação para garantir que a View não desapareça de forma abrupta. Como faremos isso?

Primeiro, criamos uma extensão UIApplication para encontrar a janela principal (getKeyWindow). Em seguida, adicionamos o modificador .transition para a SnackbarErrorView para que ela desapareça suavemente.
Usamos .onAppear() para iniciar uma contagem após a view aparecer, após 3 segundos, ajustamos o isShowing para false, que irá desencadear a view para desaparecer.

Notamos o uso do bloco withAnimation para garantir que a transição seja não perturbe o usuário. Assim, a SnackbarErrorView será exibida quando isShowingSnackBar for verdadeira e desaparecerá suavemente após 3 segundos.

import Foundation
import UIKit

extension UIApplication {
    var getKeyWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}

if isShowingSnackBar {
    SnackBarErrorView(isShowing: $isShowingSnackBar, message: errorMessage)
        .transition(.move(edge: .bottom))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isShowing = false
                }
            }
        }
}

@@06
Para saber mais: animações e transições em SwiftUI

Olá, aprendiz! Estou aqui hoje para te ensinar algo super interessante: como criar animações e transições utilizando a SwiftUI! Confuso? Não se preocupe! Este tópico pode parecer assustador, mas com a abordagem certa, você pode se tornar um mestre em animações e transições em nenhum tempo.
Fundamentos da Animação
A primeira coisa que você precisa entender é o conceito de animação. Animar é dar vida, é criar movimento. No contexto do desenvolvimento de softwares, animações são usadas para tornar a interface do usuário mais agradável, dinâmica, tornando a interação do usuário mais intuitiva e divertida. Agora, ao falar sobre SwiftUI, estamos nos referindo à estrutura de interface do usuário inovadora da Apple, que permite o desenvolvimento de interfaces fantásticas para todos os dispositivos Apple de forma declarativa.

Motivação
Se aventurar nas águas da animação e transição na SwiftUI nos dá o poder de criar aplicativos com aparência profissional e polida, melhorando a experiência do usuário. Com essas técnicas, você pode mover, dissolver, escalar e realizar todos os tipos de animações em componentes da sua IU, dando um toque a mais à sua criação.

Adicionando Animações em SwiftUI
Então, como podemos criar animações no SwiftUI? Bem, o SwiftUI torna a facilita a nossa vida com .animation().

struct ContentView: View {
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        Button("Tap Me") {
            self.animationAmount += 1
        }
        .padding(50)
        .background(Color.red)
        .foregroundColor(.white)
        .clipShape(Circle())
        .scaleEffect(animationAmount)
        .animation(.default)
    }
}
COPIAR CÓDIGO
Aqui criamos um botão que aumentará seu tamanho cada vez que for pressionado. A função .animation() modifica a maneira como as mudanças vão ocorrer a cada vez que 'animationAmount' for atualizado.

Vamos Falar sobre Transições
Então, o que vem a ser uma transição? Uma transição é a animação que ocorre quando um componente é inserido ou removido da IU. No SwiftUI, as transições são aplicadas usando a modificação .transition().

Um exemplo de código com transição básica é o seguinte:

struct ContentView: View {
    @State private var isShowingRed = false

    var body: some View {
        VStack {
            Button("Tap Me") {
                withAnimation {
                    self.isShowingRed.toggle()
                }
            }

            if isShowingRed {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 200, height: 200)
                    .transition(.scale)
            }
        }
    }
}
COPIAR CÓDIGO
No exemplo acima, quando o botão é pressionado, o retângulo vermelho é adicionado ou removido da árvore de visualizações e a transição é aplicada, ou seja, se aparece ou desaparece com um efeito de escala.

Por hora, é isso, aprendiz! Espero que este tópico sobre animações e transições em SwiftUI tenha ficado mais claro para você. Continue praticando e não se esqueça de se divertir enquanto aprende. Até a próxima!

@@07
O que aprendemos?

Nessa aula, você aprendeu como:
Corrigindo Mensagens de Erro: Vimos como corrigir um problema onde todas as mensagens de erro eram classificadas como "erro desconhecido" e aprendemos a configurar mensagens de erro específicas a partir do backend.
Priorizando a Experiência do Usuário: Reforçamos a ideia de sempre manter o usuário informado sobre o que está acontecendo no aplicativo, utilizando, neste caso, o widget snackbar para comunicar erros.
Configurando o Snackbar: Aprendemos a configurar o nosso snackbar para que ele desapareça depois de um certo tempo, dando foco na usabilidade do usuário.
Implementação do OnAppear: Este recurso funciona para determinar o que queremos que uma view faça assim que ela seja exibida na tela. Neste vídeo, foi utilizado para fazer o snackbar desaparecer depois de um tempo.
Adicionando Transições: Adicionamos uma transição ao snackbar para que ele apareça de cima para baixo na tela.

#### 29/04/2024

@04-Skeleton

@@01
Projeto da aula anterior

Você pode revisar o seu código e acompanhar o passo a passo do desenvolvimento do nosso projeto e, se preferir, pode baixar o projeto da aula anterior.
Bons estudos!

@@02
Uso de Skeleton para carregamento de informações

De volta ao nosso projeto, vamos continuar falando sobre tratamento de erros. Agora, vamos abordar um caso de uso comum em todos os aplicativos: o carregamento de informações.
Problema de carregamento inicial
Vamos gerar uma compilação build para começarmos a pensar a respeito. Como estamos rodando o projeto da API localmente na porta 3000, o tempo de resposta do servidor para o cliente (ou seja, para o aplicativo) é quase imperceptível. Não vemos nenhum tempo de espera, mas sabemos que, na vida real, a situação é diferente. Existem vários fatores que podem atrasar o retorno das informações para a pessoa usuária.

Código que simula atraso (sleep())
Para simular esse problema, vamos acessar o arquivo HomeView.swift. Na linha 47, temos o método onAppear(). Assim que a vista é desenhada, o trecho de código abaixo é executado. É feita uma chamada para a API local e são retornados os especialistas.

HomeView.swift:
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
COPIAR CÓDIGO
Vamos usar o código sleep(4) na linha 50. Este código faz com que o aplicativo fique travado por quatro segundos, simulando o tempo de resposta de um servidor para o aplicativo. Com isso, será mais fácil visualizar o caso de uso desejado.

sleep(4)
COPIAR CÓDIGO
Agora, vamos rodar o projeto no simulador. Observe como ele fica com uma tela branca por vários segundos até carregar. Na prática, na vida real, é assim que acontece. Temos com a tela branca com a frase "Veja abaixo os especialistas da Vollmed disponíveis e marque já a sua consulta!", apresentando um tempo de espera para a pessoa usuária.

É nisso que vamos trabalhar agora!

Implementação do Skeleton
Em casos onde precisamos esperar o retorno da informação, é comum usar um componente chamado skeleton (esqueleto, em português). Basicamente, desenhamos o que deveria ser visto (neste caso, os cartões de médicos) de uma forma que informa à pessoa usuária que o aplicativo está tentando buscar esses dados. A ideia é criar um skeleton para essa lista, mostrando ao usuário que o aplicativo tenta buscar os dados. Assim que conseguir, ele os mostrará na tela.

Isso é muito mais amigável para a pessoa usuária entender o que está acontecendo, do que não mostrar nada. Dá a impressão de que o aplicativo está travado ou que não vai buscar nenhuma informação.

Para começar, precisamos pensar em qual momento isso deveria acontecer. Com base nisso, precisaríamos de uma variável de controle para saber se mostramos ou não o skeleton.

Vamos começar criando uma variável de controle no arquivo HomeView.swift. Na parte superior, onde temos algumas variáveis nas linhas 16, 17 e 18, vamos criar mais uma, logo abaixo de isShowingSnackBar, chamada isFetchingData.

Essa variável booleana nos informa se o aplicativo está buscando os dados. Inicialmente, ela será verdadeira (true), assim, ao inicializar o aplicativo, começaremos mostrando o skeleton. Quando o servidor devolver a resposta para o aplicativo, mudamos para false e mostramos as informações reais.

@State private var isFetchingData = true
COPIAR CÓDIGO
Agora vamos voltar ao local onde desenhamos os cards (SpecialistCardView na linha 41), cada especialista médico é um card. Acima disso, começaremos a implementar o skeleton.

Primeiramente, vamos verificar se a variável isFetchingData é verdadeira. Se for, mostraremos o skeleton, caso contrário, manteremos como está. Para fazer isso, vamos cortar o ForEach() da linha 47 e colar dentro do else, na linha 44.

Com isso, já temos uma lógica em que, ao abrir o aplicativo, buscamos os dados e mostramos o skeleton. Assim que o back-end devolver a resposta, a variável isFetchingData será falsa e vamos desenhar as informações reais na tela.

Dentro do bloco if, a ideia é criar uma nova view do skeleton que chamaremos de SkeletonView().

if isFetchingData {
    SkeletonView()
} else {
    ForEach(specialists) { specialist in
        SpecialistCardView(specialist: specialist)
            .padding(.bottom, 8)
    }
}
COPIAR CÓDIGO
Por enquanto, SkeletonView() ainda não existe, então vamos criá-la de fato. Na hierarquia de pastas do nosso projeto, temos a pasta "views", onde vamos criar uma nova pasta para o skeleton. Dentro da pasta "skeleton", vamos criar uma nova view com SwiftUI chamada SkeletonView.

SkeletonView.swift:
import SwiftUI

struct SkeletonView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SkeletonView()
}
COPIAR CÓDIGO
Ele traz por padrão a estrutura que já conhecemos. Vamos teclar o atalho "Command + Option + Enter" para abrir a pré-visualização e conseguirmos ver os componentes que vamos desenhar.

A ideia é criarmos um card parecido com o de especialistas. Então, vamos começar colocando no lugar de Text() um Vertical Stack View (VStack()). Passaremos entre parênteses o alignment para .leading, ou seja, começando à esquerda.

Dentro desse VStack(), vamos colocar um Horizontal Stack View (HStack), porque vamos ter uma imagem e dois textos lado a lado. Então, precisamos de um HStack, onde vamos ter uma imagem, e dentro um VStack com duas labels.

O HStack vai ter um espaçamento entre a imagem e os textos. Então, vamos usar spacing com o valor 16.

struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
            
            }
        }
    }
}
COPIAR CÓDIGO
Temos então um VStack, e dentro dele um HStack. O skeleton, por padrão, tem um efeito degradê. Vamos acessar o navegador e buscar por "skeleton iOS". Em "Imagens", temos um exemplo com um círculo cinza e dois retângulos cinza ao lado. É basicamente isso o skeleton que vamos desenvolver.

No nosso caso, temos uma imagem e dois textos. Vamos começar criando um LinearGradient() para a imagem, onde vamos passar uma cor gradient: Gradient(). Para esse gradiente, podemos definir algumas cores. Usaremos o parâmetro colors, onde podemos passar, por exemplo, começando com .gray, depois .white, e depois novamente o .gray.

Vamos começar da esquerda para a direita, então o startPoint é no .leading, e o endPoint é no .trailing.

Esse é o efeito que vamos utilizar, mas apenas em um círculo. Para isso, criaremos uma máscara. A máscara será o círculo que vamos adicionar. Então, digitamos .mask(). Dentro disso, criaremos o círculo, então incluímos Circle(). Para definir o tamanho, utilizaremos o .frame(), onde passaremos uma largura (width) de 60 e uma altura (height) também de 60. Por fim, o alinhamento (alignment) será à esquerda, isto é, .leading.

Esse é o tamanho do círculo. Agora vamos colocar um tamanho igual no gradiente. Nesse caso, utilizaremos basicamente a mesma linha 17 para colocar a altura e a largura. Então, podemos copiar e colar na linha 19. O único parâmetro que não teremos será o alignment.

struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                LinearGradient(gradient: Gradient(colors: [.gray, .white, .gray]), startPoint: .leading, endPoint: .trailing)
                    .mask(
                        Circle()
                            .frame(width: 60, height: 60, alignment: .leading)
                    )
                    .frame(width: 60, height: 60)
            }
        }
    }
}
COPIAR CÓDIGO
Conclusão
É basicamente com isso que vamos começar a trabalhar. Por enquanto, ainda não temos o formato do skeleton, mas já começamos a criar a view desse esqueleto. A seguir, continuamos com os próximos componentes que precisamos configurar no esqueleto da página inicial do nosso aplicativo!

@@03
Implementando Skeleton na home

Nós havíamos criado uma nova pasta dentro de "views" chamada "skeleton", onde temos o arquivo SkeletonView.swift. Nesse arquivo, temos um LinearGradient() que cria um círculo, usando algumas cores configuradas na linha 14. Vamos continuar!
Continuando a implementação do Skeleton
Logo após o .frame() da linha 19, vamos criar outro LinearGradient(). Porém, agora vamos utilizar um VStack, pois teremos dois retângulos com gradiente, portanto, vamos empilhá-los verticalmente. Por isso, vamos utilizar o Vertical Stack View.

Vamos aproveitar para configurar o alinhamento dele. O alignment será em .leading e haverá um espaçamento de 8.

No VStack, vamos criar dois LinearGradient(). Começaremos pelo primeiro, para o qual precisamos passar um gradiente, portanto, vamos escolher o segundo construtor. Ele espera um objeto do tipo Gradient, então, vamos instanciá-lo passando algumas cores. As cores serão iguais às configuradas anteriormente, começando com .gray (cinza), depois .white (branco) e .gray novamente. Vamos iniciar da esquerda para a direita, então, startPoint: .leading e endPoint: .trailing.

Agora, vamos colocar uma máscara para o gradiente. Então, vamos chamar a função .mask() e entre parênteses, vamos criar dois textos (Text()). No nosso caso, esses textos simulam a escrita de um nome de um especialista, por exemplo.

Para o primeiro Text(), vamos criar uma nova string chamada placeholderString e, em seguida, usaremos o método .redacted(). Esse método oculta o Text(), usando como base a placeholderString, aplicando o gradiente que criamos.

SkeletonView.swift:
VStack(alignment: .leading, spacing: 8.0) {
    LinearGradient(gradient: Gradient(colors: [.gray, .white, .gray]), startPoint: .leading, endPoint: .trailing)
        .mask(
            Text(placeholderString)
                .redacted(reason: .placeholder)
            )
}
COPIAR CÓDIGO
Nesse momento, o código apresenta um erro, pois o placeholderString da linha 24 não existe. Portanto, vamos criar. Acima na linha 12, criaremos um private var placeholderString, que receberá algum caractere especial. Por exemplo, vamos adicionar uma repetição de asteriscos. Estes serão os caracteres ocultos para exibir no LinearGradient().

private var placeholderString = "********************************"
COPIAR CÓDIGO
A ideia é configurar mais um LinearGradient() como esse. Portanto, vamos copiar o que acabamos de criar, da linha 25 até a 29, e colar na linha 31. Agora, vamos rodar o projeto para verificar o resultado. Para isso, vamos gerar um build e testar.

Temos o simulador aberto, com uma view chamada skeleton que representa o card de especialistas. No momento, ela está um pouco estática, mas mais adiante, vamos adicionar uma animação para proporcionar o efeito de carregamento. Isso mostra que o aplicativo está tentando carregar algo. Essas micro interações também são muito úteis em aplicativos, para tratar situações de carregamento de informações e coisas semelhantes.

A parte principal do skeleton está pronta. Uma coisa importante a notar é que toda essa implementação representa apenas um card do skeleton. Seria interessante inserir mais 3 ou 4, para preencher todo o tamanho da tela, até que as informações estejam disponíveis. Portanto, vamos criar uma nova struct na linha 42 chamada SkeletonRow.

Essa struct é uma View que contém tudo que desenvolvemos no SkeletonView. Portanto, vamos recortar o VStack inteiro (da linha 15 até a linha 38) e colar dentro do body da struct que criamos. Além disso, vamos copiar a variável placeholderString e mover para acima do body, dentro de SkeletonRow.

struct SkeletonRow: View {

    private var placeholderString = "********************************"

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                LinearGradient(gradient: Gradient(colors: [.gray, .white, .gray]), startPoint: .leading, endPoint: .trailing)
                    .mask(
                        Circle()
                            .frame(width: 60, height: 60, alignment: .leading)
                    )
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 8.0) {
                    LinearGradient(gradient: Gradient(colors: [.gray, .white, .gray]), startPoint: .leading, endPoint: .trailing)
                        .mask(
                            Text(placeholderString)
                                .redacted(reason: .placeholder)
                        )

                    LinearGradient(gradient: Gradient(colors: [.gray, .white, .gray]), startPoint: .leading, endPoint: .trailing)
                        .mask(
                            Text(placeholderString)
                                .redacted(reason: .placeholder)
                        )
                }
            }
        }
    }
}
COPIAR CÓDIGO
Isso representa um único card. A ideia do SkeletonView é ter várias SkeletonRow. Então, dentro do body da linha 14, vamos criar uma VStack, pois vamos adicionar várias SkeletonRow uma abaixo da outra, e dentro dela faremos um ForEach(). A condição será: iniciar do 0 e ir até o 4.

Quando trabalhamos com objetos que não têm identifiable, que não seguem o protocolo, precisamos passar um identificador. Podemos fazer isso adicionando \.self. Dessa forma, é atribuído um identificador a cada elemento que o ForEach() itera. Dentro do identificador, chamaremos SkeletonRow().

struct SkeletonView: View {
    var body: some View {
        VStack {
            ForEach(0..<4, id: \.self) { index in
                SkeletonRow()
            }
        }
    }
}
COPIAR CÓDIGO
Conclusão
Recapitulando, criamos uma SkeletonRow, que representa um único card. Dentro do SkeletonView, criamos um ForEach() para que ele passe quatro vezes e desenhe quatro vezes o SkeletonRow. Vamos testar o aplicativo novamente.

Agora, temos a view do skeleton na tela. Ela está muito mais parecida com os dados que o aplicativo vai carregar e temos a representação quatro vezes. Ainda precisamos corrigir alguns problemas de espaçamento e adicionar a animação, que é a parte mais interessante, mas continuaremos falando do skeleton na próxima aula!

@@04
Carregando Skeletons

Imagine que você é da equipe de desenvolvimento na Clínica Médica Voll. Dentre suas tarefas está a melhoria na experiência do usuário ao utilizar o novo aplicativo da clínica, o "VollMed". Parte dessa melhoria envolve a implementação de uma funcionalidade chamada "Skeleton", que visa oferecer um feedback visual ao usuário durante o carregamento de páginas que precisam buscar muitos dados, como a lista de médicos especialistas.
Considerando o status da variável isFetchingData, quais partes do código serão executadas durante o carregamento dos dados e o que será mostrado para o usuário?


Alternativa correta
SkeletonView() será executado e o usuário verá vários retângulos cinzas empilhados.
 
A estrutura condicional if no corpo de HomeView verifica o status da variável isFetchingData. Se esta for true (indicando que os dados estão sendo carregados), o código executa SkeletonView(). Essa função cria uma interface temporária com os elementos VStack, HStack, Circle e Rectangle que dão ao usuário uma visualização de retângulos cinzas empilhados.
Alternativa correta
O SkeletonView() vai exibir os dados verdadeiros, o usuário verá a lista de médicos especialistas imediatamente ao abrir o app.
 
Alternativa correta
SkeletonView() será executado e o usuário verá uma tela em branco.

@@05
Faça como eu fiz: Design Skeleton

A Clínica Médica Voll acabou de lançar um novo aplicativo chamado "VollMed" para melhorar a experiência digital de seus pacientes. A interface do aplicativo inclui uma funcionalidade que permite aos usuários visualizar uma lista de médicos especialistas. Dada a quantidade de dados requeridos para esta funcionalidade, o carregamento da informação pode levar alguns segundos, o que pode resultar em uma experiência ruim para os usuários. Portanto, você recebeu a demanda para projetar um componente de interface do usuário chamado "Skeleton" que será exibido durante o carregamento dos dados para melhorar a experiência geral do usuário. Sua tarefa é criar esse "Skeleton" com o uso da linguagem de programação Swift.

Comece identificando o momento em que o Skeleton será exibido para o usuário. Crie uma variável de controle para saber se está carregando os dados. Inicialize a variável como true para iniciar o aplicativo mostrando o Skeleton.
Em seguida, crie condições para exibir o Skeleton ou os dados verdadeiros dependendo do status da variável de controle. Neste ponto, você precisará criar o componente de interface do usuário Skeleton.

Finalmente, crie múltiplas linhas do Skeleton para simular a lista de médicos especialistas que será carregada.

Há várias etapas e blocos de código que você precisará adicionar para completar este exercício. Você está pronto para o desafio?

import SwiftUI

struct HomeView: View {
    @State private var isFetchingData = true
    var body: some View {
        if isFetchingData {
            SkeletonView()
        } else {
            //Código para exibir os dados verdadeiros
        }
    }
}
struct SkeletonView: View {
    var body: some View {
        VStack {
            ForEach(0..<3) {_ in
                HStack {
                    Circle().fill(Color.gray).frame(width:60, height:60)
                    VStack(alignment: .leading) {
                        Rectangle().fill(Color.gray).frame(height:20)
                        Rectangle().fill(Color.gray).frame(height:20)
                    }
                }
            }
        }
    }
}
COPIAR CÓDIGO
Nesta solução, estamos criando uma variável chamada isFetchingData para controlar se estamos atualmente pegando os dados. Se isFetchingData for true, mostramos o SkeletonView, caso contrário, mostramos os dados verdadeiros. O SkeletonView é uma representação visual de uma lista que é exibida enquanto estamos buscando os dados.

@@06
O que aprendemos?

Nessa aula, você aprendeu como:
Implementação de um Skeleton View: Passamos pelo processo de criar um esqueleto para melhorar a experiência de carregamento do aplicativo, também discutimos a necessidade de usar esse esqueleto.
Utilizando VStackView: Explicado como empilhar retângulos com gradient, utilizando o VStackView e ajustando o alinhamento e espaçamento.
Aplicando Máscaras de Texto: Foi ensinado como utilizar máscaras de texto para simular a escrita de um nome de um especialista.
Implementando uma Struct Skeleton Row: Foi criada uma nova Struct denominada Skeleton Row que representa um único card, repetido várias vezes no Skeleton View.

#### 30/04/2024

@05-Animação de loading

@@01
Projeto da aula anterior

Você pode revisar o seu código e acompanhar o passo a passo do desenvolvimento do nosso projeto e, se preferir, pode baixar o projeto da aula anterior.
Bons estudos!

@@02
Implementando animações

Para finalizar o Skeleton, arrumaremos o problema de espaçamento entre uma linha e outra. Por fim, incluiremos a animação para dar o efeito de carregamento de dados, conhecido como loading.
Corrigindo o espaçamento
Com o arquivo SkeletonView aberto, na linha 12, temos um VStack onde, a cada iteração do for, incluímos um SkeletonRow. Agora, no VStack, adicionamos parênteses e passamos spacing: 35, com isso o problema deve ser resolvido.

Para conferir, rodamos o projeto novamente e notamos que deu certo. Agora, podemos partir para a animação.

Implementando a animação
Implementaremos uma animação chamada redacted, que oculta os dados e exibe os dados, criando um efeito de carregamento.

Para isso, na pasta "Extensions", onde temos algumas extensões para serem utilizadas em outros lugares do projeto, criaremos a animação. Para isso, clicamos com o botão direito nela e depois em "New File". Selecionamos a opção "Swift File" e depois clicamos em "Next". Na janela seguinte, nomeamos o arquivo de RedactedAnimationModifier, copiamos o nome e clicamos o botão "Create".

Começaremos criando uma struct com o nome do arquivo RedactedAnimationModifier, adicionamos dois pontos e passamos o modificador chamado ViewModifier. Ao trabalhar com SwiftUI, podemos modificar o comportamento de algumas views utilizando o ViewModifier.

Modificaremos o comportamento de uma view de SwiftUI, para isso, precisamos implementar o protocolo ViewModifier.
Repare que aparece um aviso na lateral da ferramenta, pois precisamos importar o SwiftUI. Para corrigir, na linha 9, passamos import SwiftUI.

import SwiftUI

O struct RedactedAnimationModifier: ViewModifier {
COPIAR CÓDIGO
Agora, precisamos implementar algum método, para sabermos qual, na mensagem de erro, clicamos no botão "Fix", localizado na lateral direita da tela. É recomendado que implementemos o body, um método.

Se no fim do código escrevermos body e escolhermos a opção sugerida pela ferramenta body(content:), é implementado o método abaixo:

func body(content: content) -> some View {
}
COPIAR CÓDIGO
É dentro desse método que trabalharemos com a animação. Na linha abaixo de body(), escrevemos content. A partir dele, podemos alterar algumas propriedades, como, por exemplo, a opacidade, que fará o efeito de aparecer e desaparecer. Para isso, na linha abaixo escrevemos .opacity().

Para isso, precisamos de uma variável para indicar se devemos deixar com mais opacidade ou menos. Na linha 12 escrevemos @State private var isRedacted igual à true.

Agora, nos parênteses de opacity(), faremos algumas verificações, então passamos isRedacted ? 0 : 1, assim, se a variável for verdadeira o valor será 0, caso não, 1.

Também podemos fazer algumas alterações quando a view que implementar a animação aparecer. Para isso, passamos .onAppear {}. Na linha abaixo, passamos o método withAnimation. Repare que ao digitar, a ferramenta indica algumas opções, escolhemos o withAnimation(_ body:).

import SwiftUI

struct RedactedAnimationModifier: ViewModifier {

        @State private var isRedacted = true

        func body (content: Content) -> some View {
    content
            .opacity(isRedacted ? 0 : 1)
            .onAppear {
                    withAnimation (animation: Animation?, body: () throws -> Result)
            }
        }
}
COPIAR CÓDIGO
Em withAnimation(), passamos nos parênteses Animation.easeInOut(). Dos parênteses, passamos duration: 0.7. Feito isso, apagamos o trecho de código de body.

Adicionamos chaves e dentro, alteraremos o valor de redacted. Escrevemos sef.isRedacted.toggle(). Além disso, acrescentaremos uma repetição. Na linha 18, após duration, escrevemos .repeatForever(autoreverses:true).

import SwiftUI

struct RedactedAnimationModifier: ViewModifier {

        @State private var isRedacted = true
        
        func body (content: Content) -> some View {
            content
                .opacity (isRedacted ? 0 : 1)
                .onAppear {
                        withAnimation (Animation.easeInOut (duration: 0.7). repeat Forever (autoreverses: true)) {
                            self.isRedacted.toggle()
                        }
                }
        }
}
COPIAR CÓDIGO
Com isso, já podemos começar a testar. Como essa animação poderá ser feita em qualquer parte do projeto, criaremos uma extensão de view onde fechamos a struct do RedactedAnimationModifier, na linha 23.

Escrevemos extension View {}. Nas chaves, na linha abaixo, escrevemos func redactedAnimation(). Em seguida, passamos uma view -> some View {}. Nas chaves, passamos modifier() e nos parênteses RedactedAnimationModifier().

extension View {
        func redactedAnimation() -> some View {
            modifier (RedactedAnimationModifier()])
        }
}
COPIAR CÓDIGO
Assim, temos uma extensão e a implementação da animação. Agora ficará mais claro quando testarmos, pois colocamos o método repeatForever e a opacidade.

SkeletonView
Para que tudo funcione, precisaremos fazer algumas alterações. Então, abrimos novamente o arquivo SkeletonView. Em Circle(), na linha abaixo de .frame(), podemos colocar essa animação. Na linha 30, configuramos a altura e largura, então, na 31 escrevemos .redactedAnimation(), que é a extensão que criamos.

//Código omitido

Circle()
    .frame(width: 60, height: 60, alignment: .leading)
    .redactedAnimation()

//Código omitido
COPIAR CÓDIGO
Na linha 40, abaixo de.redacted(), também chamamos o redactedAnimation.

//Código omitido

Text(placeholderString)
        .redacted(reason: .placeholder)
        .redactedAnimation()
        
//Código omitido
COPIAR CÓDIGO
Para finalizar, dentro do LinearGradient(), na linha 47, passamos o redactedAnimation().

//Código omitido

LinearGradient(gradient: Gradient(colors: [.gray, white, .gray]),
        startPoint: .leading, endPoint: .trailing)
        .mask(
            Text(placeholderString)
                    .redacted(reason: .placeholder)
                    .redactedAnimation()|
        )
        
//Código omitido
COPIAR CÓDIGO
Animação pronta, agora vamos testar. Abrimos o simulador e notamos que a animação que criamos está sendo exibida na tela.

Abaixo do texto "Veja abaixo os especialistas da Vollmed disponíveis e marque já a sua consulta" há um círculo na cor cinza, que se refere ao espaço da foto do especialista da Vollmed. Ao lado direito duas linhas cinzas, que se referem aos dados desse especialista que aparecerá na tela. Esses elementos ficam piscando na tela, como se fosse o efeito de carregamento dos dados.

Vários aplicativos utilizam essa animação, principalmente as redes sociais. Qualquer aplicativo que busque dados no servidor pode utilizar o SkeletonView. Esse recurso ajuda a dar a sensação ao usuário de que o aplicativo está tentando buscar uma informação.
Nesse caso, criamos um Skeleton para colocar em prática os conceitos aprendidos de SwiftUI e um pouco de animação. Porém, também há bibliotecas que possuem o skeleton pronto para o projeto.

HomeView
Um ponto importante é que em HomeView, usamos o sleep para simular essa demora na requisição e não definimos a variável para esconder o skeleton. Faremos isso.

Dependendo da versão do iOS que você estiver usando, pode ser que a animação não funcione. Então, uma forma de testar é apagando o sleep(4) da linha 56 e em seguida derrubar o servidor através do terminal.

Para isso, basta abrir o terminal e apertar o comando "Ctrl+C", após derrubar a conexão será possível rodar o projeto e ver a animação do skeleton. Ao abrir a aplicação, repare que aparece um erro e depois o skeleton.

É importante definirmos o valor da variável de animação, então, na linha 56, escrebemos isFetchingData igual à false. Assim que ele retornar a resposta, definimos como falso e conseguimos de fato mostrar as informações dos especialistas.

//Código omitido

Task {
        do {
                isFetchingData = false
                guard let response = try await viewModel.getSpecialists() else {
                        return }
                self.specialists = response
} catch {
                isShowingSnackBar = true
                let errorType = error as? RequestError
                errorMessage = errorType?.customMessage ?? "Ops! Ocorreu um erro"
}
}
}
COPIAR CÓDIGO
Rodamos mais uma vez o projeto para analisarmos o skeleton. Ainda aparece um erro, pois o servidor está desabilitado, em seguida, como colocamos o false, não será exibido o skeleton porque está caindo no erro. Mas se voltarmos a conexão no terminal e com o comando npm start e buildar o projeto novamente.

Feito isso, as fotos e dados dos especialistas aparecem na tela. Como é um servidor local muito rápido, não conseguimos de fato visualizar o tempo de demora do carregamento. Mas com o sleep, conseguimos configurar um tempo e visualizar o skeleton.

Assim, concluímos a implementação. A ideia foi compartilhar alguns insights de tratamento de erros gerais no nosso aplicativo e como utilizar o skeleton no projeto.

@@03
Faça como eu fiz: animação de carregamento

A clínica médica Voll está trazendo melhorias para sua plataforma online. Para melhorar a experiência de uso do app, eles querem adicionar uma animação de carregamento para quando os dados dos médicos especialistas estão sendo carregados. Para isso, você irá implementar uma animação Redacted em Swift. Redacted é um efeito que temporariamente oculta o conteúdo de uma View. É comumente usado para mostrar um placeholder enquanto os dados reais são carregados em segundo plano. Sua tarefa é modificar a view existente (Skeleton) para adicionar a animação.

Dentro da pasta Extensions, crie um novo arquivo chamado RedactedAnimationModifier. Aqui está o código:
import SwiftUI

struct RedactedAnimationModifier: ViewModifier {
    @State private var isRedacted = true

    func body(content: Content) -> some View {
        content
            .opacity(isRedacted ? 0 : 1)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    self.isRedacted.toggle()
                }
            }
    }
}

extension View {
    func redactedAnimation() -> some View {
        modifier(RedactedAnimationModifier())
    }
}
COPIAR CÓDIGO
Agora, precisamos chamar essa animação dentro do Skeleton:

struct SkeletonRow: View {
    var body: some View {
            VStack(spacing: 35) {
                 ForEach(0..<4, id: \.self) { index in
                     SkeletonRow()
                }
            }
    }
}
COPIAR CÓDIGO
A animação está pronta! Você modificou a View para adicionar a animação Redacted, criando uma experiência de usuário mais agradável ao carregar dados.

@@04
Carregando Skeletons

Você faz parte da equipe de desenvolvimento da Clínica Médica Voll e é responsável pela melhoria da experiência do usuário no aplicativo "VollMed". Você foi incumbido de implementar a animação "Redacted", que tem como função ocultar temporariamente o conteúdo de uma View enquanto os dados estão sendo carregados. A ideia é melhorar a experiência do usuário ao carregar os dados dos médicos especialistas. Suponha que houve uma falha na conexão com a internet e os dados dos médicos especialistas estão demorando mais do que o previsto para serem carregados.
Baseado no projeto da aula, qual seria a experiência do usuário durante este período de carregamento prolongado?

O usuário verá um círculo em constante rotação, indicando que os dados estão sendo carregados.
 
Alternativa correta
Os retângulos cinzas empilhados, aparecerão e desaparecerão continuamente com um efeito de fade.
 
O efeito "Redacted" é implementado de tal forma que os retângulos cinzas criados pelo SkeletonView() aparecem e desaparecem continuamente, criando um efeito de carregamento.
Alternativa correta
O usuário verá uma tela totalmente em branco.

@@05
Projeto final

Você pode baixar ou acessar o código-fonte do projeto final.
Aproveite para explorá-lo e revisar pontos importantes do curso.

Bons estudos!

https://github.com/alura-cursos/3367-swift-tratamento-de-erros/archive/refs/heads/aula-5.zip

https://github.com/alura-cursos/3367-swift-tratamento-de-erros/tree/aula-5

@@06
O que aprendemos?

Nessa aula, você aprendeu como:
Configurando espaçamento: No começo do vídeo, é mostrado como arrumar o espaçamento entre as linhas de um Skeleton. Isso é feito ao colocar um espaçamento de 35 na linha 12 do arquivo SkeletonView.
Inclusão de animação: A animação Redacted é introduzida para dar um efeito de carregamento de dados. Essa animação deixa os dados ocultos e eles aparecem e desaparecem, dando um efeito de carregamento real.
Utilizando ViewModifier: É explicado que quando se trabalha com SwiftUI, podemos modificar o comportamento de algumas views utilizando o ViewModifier. Neste caso, a animação é implementada através de um protocolo ViewModifier.
Criando e usando extensão de View: Uma extensão de View é feita para possibilidades de uso da animação em qualquer parte do projeto. Isso é feito ao criar um método na extensão de View que usa o modificador e passa a struct declarada anteriormente.
Manipulando opacidade: Aprende-se como controlar o efeito de aparecer e desaparecer através da alteração da opacidade dos dados. Isso é feito com a ajuda de uma variável chamada isRedacted.

@@07
Recados finais

Parabéns, você chegou ao fim do nosso curso. Tenho certeza que esse mergulho foi de muito aprendizado.
Após os créditos finais do curso, você será redirecionado para uma tela na qual poderá deixar seu feedback e avaliação do curso. Sua opinião é muito importante para nós.

Aproveite para conhecer a nossa comunidade no Discord da Alura e se conectar com outras pessoas com quem pode conversar, aprender e aumentar seu networking.

Continue mergulhando com a gente 🤿.

@@08
Conclusão

Parabéns por concluir mais um curso de iOS!
Nessa jornada, você aprendeu vários tópicos de tratamento de erro que serão muito importantes na sua vida profissional.

Antes de concluir, vamos relembrar o que aprendemos!

Primeiro, estudamos um pouco sobre status code. Em cursos anteriores, falamos sobre casos de erros que mapeamos na classe RequestError.

Porém, nesse curso, o objetivo era pensar em erros que o back-end define e retorna para o aplicativo. Então, criamos um erro customizado onde recebemos uma mensagem do back-end para mostrar ao usuário.

Depois disso, discutimos como poderíamos apresentar essas informações de erro para o usuário. Nisso, reforçamos a importância de manter o usuário informado de tudo o que está acontecendo no app.

Aprendemos como criar um alert controller padrão do iOS, ou criar uma view customizável, que foi o que fizemos.

Criamos a view do SnackBarErrorView, onde implementamos em SwiftUI uma view para ser utilizada para diversos tipos de erros no app, permitindo assim mostrar mensagens de erro ao usuário. Também mexemos um pouco com animação, controlando como a view aparece e desaparece.

Em seguida, pensamos em outros casos de uso, como do skeleton. Quando abrimos um aplicativo, ou uma tela dele, é normalmente feita uma requisição para um servidor, e essa requisição pode levar segundos até retornar informações.

Consideramos que o skeleton é uma boa prática para indicar ao usuário que o aplicativo está carregando informações. Criamos então um card de especialistas utilizando um gradiente de cinza para branco e também a linha para cada item, como nome e especialidade do profissional da saúde.

Por fim, falamos um pouco sobre animação. Criamos a view modifier com o efeito de redacted, onde alteramos a opacidade da view conforme a variável isRedacted, que também criamos na struct. Para utilizar esse efeito em várias partes do aplicativo, criamos uma extensão.

Esse foi o conteúdo aprendido durante todo esse curso de tratamento de erros. Esperamos que você tenha gostado e que coloque em prática todo aprendizado nos seus projetos pessoais e corporativos.

Caso você tenha alguma dúvida ou deseja interagir com outros alunos que estão passando pelo mesmo processo de aprendizagem, sinta-se convidado a participar da nossa comunidade do Discord.

Ao concluir o curso, você será direcionado à página de avaliação. Seu feedback é muito importante para podermos continuar evoluindo.

Até a próxima!