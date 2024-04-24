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