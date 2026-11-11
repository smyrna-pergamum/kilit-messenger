// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Kilit';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get share => 'Compartilhar';

  @override
  String get lockNow => 'Bloquear agora';

  @override
  String get panicTooltip =>
      'Toque para bloquear, segure para o código de pânico';

  @override
  String get panicNoCode =>
      'Defina primeiro um código de pânico nas Configurações.';

  @override
  String get panicEnterTitle => 'Código de pânico';

  @override
  String get panicEnterHint =>
      'Digite o código de pânico para apagar tudo no Kilit.';

  @override
  String get panicWrong => 'Esse não é o código de pânico.';

  @override
  String get settingsPanic => 'Código de pânico';

  @override
  String get panicExplain =>
      'Quatro dígitos. Digitado na tela de bloqueio no lugar do seu PIN, ou depois de segurar o botão de bloqueio, ele apaga para sempre todas as chaves, mensagens e arquivos do Kilit, e o Kilit recomeça como se tivesse acabado de ser instalado.';

  @override
  String get panicStatusOn => 'Definido';

  @override
  String get panicStatusOff => 'Não definido';

  @override
  String get panicSet => 'Definir código de pânico';

  @override
  String get panicChange => 'Alterar código de pânico';

  @override
  String get panicRemove => 'Remover código de pânico';

  @override
  String get panicCreateTitle => 'Escolha um código de pânico';

  @override
  String get panicCreateHint =>
      'Quatro dígitos. Quem vir você digitá-lo pode apagar o Kilit.';

  @override
  String get panicConfirmTitle => 'Repita o código de pânico';

  @override
  String get panicMismatch => 'Os códigos não coincidem. Comece de novo.';

  @override
  String get panicSaved => 'Código de pânico definido.';

  @override
  String get panicRemoved => 'Código de pânico removido.';

  @override
  String get panicRejected => 'Este código não pode ser usado. Escolha outro.';

  @override
  String get keptInVault => 'Salvo no cofre.';

  @override
  String get alreadyInVault => 'Já está no cofre.';

  @override
  String get keptTitleFallback => 'Mensagem';

  @override
  String get devBanner => 'Núcleo de desenvolvimento: sem criptografia real.';

  @override
  String get lockTitleUnlock => 'Desbloquear';

  @override
  String get lockTitleCreate => 'Escolha um PIN';

  @override
  String get lockTitleConfirm => 'Digite o PIN de novo';

  @override
  String get lockHintUnlock => 'Digite seu PIN para abrir o cofre.';

  @override
  String lockHintCreate(int min) {
    return 'Pelo menos $min dígitos. Se você esquecer, o cofre não poderá ser aberto: não há recuperação.';
  }

  @override
  String get lockHintConfirm => 'Digite o mesmo PIN mais uma vez.';

  @override
  String get lockMismatch => 'Os PINs não coincidem. Comece de novo.';

  @override
  String get lockWrongPin => 'PIN incorreto.';

  @override
  String get settingsChangePin => 'Alterar PIN';

  @override
  String get changePinCurrent => 'Digite seu PIN atual';

  @override
  String get changePinNew => 'Escolha um novo PIN';

  @override
  String get changePinDone => 'PIN alterado.';

  @override
  String lockWait(int seconds) {
    return 'Aguarde $seconds s antes de tentar novamente.';
  }

  @override
  String pinDigitsEntered(int count) {
    return 'Dígitos digitados: $count';
  }

  @override
  String get pinDelete => 'Apagar';

  @override
  String get pinOk => 'OK';

  @override
  String get navChats => 'Conversas';

  @override
  String get navVault => 'Cofre';

  @override
  String get navCamera => 'Câmera';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get chatEmpty =>
      'Ainda não há mensagens. A primeira que você escrever inicia a sessão criptografada.';

  @override
  String get chatInput => 'Mensagem';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatNewContact =>
      'Escreveu para você sem ter sido adicionado. Aceite para responder ou bloqueie. Comparem os números de segurança antes de confiar.';

  @override
  String get safetyTitle => 'Número de segurança';

  @override
  String safetyHint(String name) {
    return 'Compare estes 60 dígitos com $name, pessoalmente ou por ligação. Se forem iguais dos dois lados, não há ninguém no meio.';
  }

  @override
  String get attachCamera => 'Câmera';

  @override
  String get attachFile => 'Foto ou arquivo';

  @override
  String get chatFileTooLarge => 'Grande demais para enviar: no máximo 5 MB.';

  @override
  String get chatDelivered => 'Entregue';

  @override
  String get fileComing => 'Recebendo…';

  @override
  String get fileToVault => 'Adicionar ao cofre';

  @override
  String get fileSavedVault => 'Adicionado ao cofre.';

  @override
  String get timerTitle => 'Mensagens temporárias';

  @override
  String get timerHint =>
      'As novas mensagens desta conversa somem após esse tempo, para vocês dois.';

  @override
  String get timerOff => 'Desligado';

  @override
  String get timer5m => '5 minutos';

  @override
  String get timer1h => '1 hora';

  @override
  String get timer1d => '1 dia';

  @override
  String get timer1w => '1 semana';

  @override
  String get renewTitle => 'Renovar meu ID do Kilit';

  @override
  String get renewBody =>
      'Você recebe palavras novas, um link novo e um QR code novo. Seus contatos continuam falando com você como antes; o ID e o link antigos param de funcionar para qualquer pessoa nova.';

  @override
  String get renewGo => 'Renovar';

  @override
  String renewDone(String id) {
    return 'Seu novo ID: @$id';
  }

  @override
  String get cameraNoCamera =>
      'Não foi possível abrir a câmera. Permita que o Kilit use a câmera nas configurações do dispositivo.';

  @override
  String get cameraShutter => 'Tirar foto';

  @override
  String get cameraRetake => 'Tirar de novo';

  @override
  String get cameraUse => 'Usar';

  @override
  String get cameraIntro =>
      'As fotos são feitas só na memória: nada é gravado no dispositivo, e elas não levam localização nem dados da câmera.';

  @override
  String get cameraSendTo => 'Enviar para…';

  @override
  String get cameraToVault => 'Guardar no cofre';

  @override
  String get cameraSavedVault => 'Foto guardada no cofre.';

  @override
  String get cameraNoContacts => 'Ainda não há contatos para enviar.';

  @override
  String cameraSent(String name) {
    return 'Enviado para $name.';
  }

  @override
  String get chatsYourKilit => 'Seu Kilit';

  @override
  String get chatsSearch => 'Pesquisar';

  @override
  String get chatsEmptyNew =>
      'Ninguém aqui ainda. Adicione alguém ou mostre seu código.';

  @override
  String get torChipReady => 'Tor pronto';

  @override
  String torChipStarting(int progress) {
    return 'Tor $progress%';
  }

  @override
  String get torChipOff => 'Tor desligado';

  @override
  String get addTitle => 'Adicionar alguém';

  @override
  String get addHint =>
      'Escaneie o código da pessoa ou cole o que ela lhe deu: um link ou um @ID.';

  @override
  String get addScan => 'Escanear o código';

  @override
  String get addField => 'Um link do Kilit ou um @ID';

  @override
  String get addGo => 'Adicionar';

  @override
  String get addSearching => 'Procurando pelo Tor…';

  @override
  String get addNotFound =>
      'Ninguém encontrado com este ID. Confira ou tente de novo em instantes.';

  @override
  String get addOffline =>
      'Ainda não conectado ao Tor. Espere aparecer Tor pronto.';

  @override
  String get addNotInvite => 'Isso não é um link do Kilit nem um @ID.';

  @override
  String get addShowMine => 'Mostrar meu código';

  @override
  String get addShowMineHint => 'Seu código QR, seu link, seu @ID';

  @override
  String get myTitle => 'Meu código';

  @override
  String get myHint =>
      'Quem tiver este código, seu link ou seu @ID pode escrever para você. A primeira mensagem espera em Pedidos até você aceitar.';

  @override
  String get myCopyLink => 'Copiar link';

  @override
  String myShareText(String id, String link) {
    return 'Me adicione no Kilit: @$id\n$link';
  }

  @override
  String get scanTitle => 'Escanear um código do Kilit';

  @override
  String get scanHint => 'Aponte a câmera para o código QR.';

  @override
  String get requestsTitle => 'Pedidos';

  @override
  String get requestsEmpty => 'Nenhum pedido.';

  @override
  String get requestHint =>
      'Escreveram para você sem terem sido adicionados. Nada chega a eles até você aceitar e responder.';

  @override
  String get requestAccept => 'Aceitar';

  @override
  String get requestDecline => 'Recusar';

  @override
  String get requestBlock => 'Bloquear';

  @override
  String get chatOnRelay => 'Nos relays';

  @override
  String get chatQueued => 'Aguardando a rede';

  @override
  String get contactRename => 'Renomear';

  @override
  String get contactRemove => 'Excluir contato';

  @override
  String get contactRemoveTitle => 'Excluir este contato?';

  @override
  String get contactRemoveBody =>
      'A sessão e toda a conversa são excluídas. Para conversar de novo, adicionem-se novamente.';

  @override
  String get contactRemoveGo => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get vaultAddNote => 'Adicionar nota';

  @override
  String get vaultCompose => 'Mensagem portadora';

  @override
  String get vaultOpenClipboard => 'Abrir da área de transferência';

  @override
  String get vaultOpenPasted => 'Abrir texto colado';

  @override
  String get vaultSealFile => 'Criptografar um arquivo';

  @override
  String get vaultOpenKlt => 'Abrir .klt';

  @override
  String get vaultEmpty =>
      'Seu cofre está vazio. Adicione uma nota ou criptografe um arquivo; tudo é guardado como um pacote .klt.';

  @override
  String get vaultSigned => 'Assinado';

  @override
  String get vaultFileTooLarge => 'O arquivo é grande demais: no máximo 64 MB.';

  @override
  String vaultFileSealed(String name) {
    return '$name foi criptografado e adicionado ao cofre.';
  }

  @override
  String vaultFileCleaned(String name, String removed) {
    return '$name foi criptografado e adicionado ao cofre. Dados ocultos removidos: $removed.';
  }

  @override
  String vaultFileUnchecked(String name) {
    return '$name foi criptografado e adicionado ao cofre. O Kilit não consegue remover dados ocultos (como o autor) deste tipo de arquivo; confira antes de compartilhar.';
  }

  @override
  String get damagedPictureTitle => 'Imagem danificada';

  @override
  String get damagedPictureBody =>
      'Esta imagem está danificada, então o Kilit não conseguiu remover seus dados ocultos, como o local onde foi tirada. Adicionar assim mesmo?';

  @override
  String get damagedPictureSeal => 'Adicionar assim mesmo';

  @override
  String get hiddenLocation => 'localização';

  @override
  String get hiddenCamera => 'dados da câmera';

  @override
  String get hiddenAuthorNotes => 'autor e notas';

  @override
  String get hiddenExtraImages => 'imagens extras';

  @override
  String get hiddenOther => 'outros metadados';

  @override
  String get hiddenListSeparator => ', ';

  @override
  String get clipboardEmpty =>
      'Nenhuma mensagem do Kilit na área de transferência. No WhatsApp, mantenha a mensagem pressionada e toque em Copiar.';

  @override
  String get clipboardBanner =>
      'Há uma mensagem do Kilit na área de transferência.';

  @override
  String get clipboardBannerOpen => 'Abrir';

  @override
  String get clipboardBannerDismiss => 'Ignorar';

  @override
  String get noteNew => 'Nova nota';

  @override
  String get noteTitle => 'Título';

  @override
  String get noteText => 'Nota';

  @override
  String get sealAndSave => 'Criptografar e salvar';

  @override
  String get carrierTitle => 'Mensagem portadora';

  @override
  String get carrierIntro =>
      'A mensagem é criptografada e vira um texto para colar em um app como o WhatsApp.';

  @override
  String get carrierMessage => 'Mensagem';

  @override
  String get withPassphrase => 'Com uma senha compartilhada';

  @override
  String get carrierWithPassphraseHint =>
      'A outra pessoa abre com a mesma senha. Desligado: só você pode abrir.';

  @override
  String get passphrase => 'Senha compartilhada';

  @override
  String get carrierPassphraseHelper =>
      'Pelo menos 12 caracteres. Não envie pelo mesmo canal da mensagem.';

  @override
  String get carrierSeal => 'Criptografar';

  @override
  String get carrierResultIntro =>
      'Copie e envie este texto. O canal só vê dados criptografados.';

  @override
  String carrierChars(int count) {
    return 'Caracteres: $count';
  }

  @override
  String get pasteTitle => 'Abrir texto colado';

  @override
  String get pasteInput => 'Texto que você copiou de uma conversa';

  @override
  String get pasteFromClipboard => 'Colar da área de transferência';

  @override
  String get passphraseIfAny => 'Senha compartilhada (se houver)';

  @override
  String get pasteOpen => 'Localizar e abrir';

  @override
  String get pasteNone => 'Nenhum pacote KLT1 encontrado no texto.';

  @override
  String get pasteTruncated =>
      'Um pacote foi cortado: o app de envio pode ter encurtado a mensagem.';

  @override
  String get pasteMalformed => 'Um pacote está danificado.';

  @override
  String get openWrongKey => 'Este pacote não abre com esta senha ou chave.';

  @override
  String get openDamaged => 'Este pacote está danificado ou foi alterado.';

  @override
  String get openIsFile =>
      'Este pacote contém um arquivo; adicione-o ao cofre com Abrir .klt.';

  @override
  String get packetTitle => 'Análise do pacote';

  @override
  String get packetFile => 'Arquivo';

  @override
  String get packetType => 'Tipo';

  @override
  String get packetSize => 'Tamanho';

  @override
  String packetSizeValue(String content, String packet) {
    return '$content (pacote $packet)';
  }

  @override
  String get packetFormat => 'Formato';

  @override
  String get packetFormatValue => 'KLT1 (baseado em age v1)';

  @override
  String get packetRecipients => 'Destinatários';

  @override
  String get packetContent => 'Conteúdo';

  @override
  String get packetContentValue => 'ChaCha20-Poly1305, blocos de 64 KiB';

  @override
  String get packetSignature => 'Assinatura';

  @override
  String get sigVerified => 'Ed25519 + ML-DSA-65, verificada';

  @override
  String get sigUnsigned => 'Sem assinatura';

  @override
  String get sigInvalid => 'INVÁLIDA';

  @override
  String get recipientXwing => 'klt-xwing (ML-KEM-768 + X25519)';

  @override
  String get recipientPassphrase => 'klt-argon2id (senha compartilhada)';

  @override
  String get itemOpen => 'Abrir';

  @override
  String get itemView => 'Ver';

  @override
  String get itemExport => 'Exportar como .klt';

  @override
  String get itemSavePlain => 'Salvar sem criptografia';

  @override
  String get savePlainTitle => 'Salvar sem criptografia?';

  @override
  String get savePlainBody =>
      'O arquivo é salvo descriptografado. Qualquer pessoa com acesso ao local onde você salvar pode lê-lo; o Kilit não poderá mais protegê-lo.';

  @override
  String get itemDelete => 'Excluir do cofre';

  @override
  String get exportTitle => 'Exportar como .klt';

  @override
  String get exportIntro =>
      'O arquivo é criptografado de novo e assinado pelo seu cofre. O nome do arquivo é aleatório; o nome real fica dentro do pacote criptografado.';

  @override
  String get exportWithPassphraseHint =>
      'Qualquer pessoa com a senha pode abrir. Desligado: só o seu cofre abre (para backups).';

  @override
  String get exportPassphraseHelper =>
      'Pelo menos 12 caracteres. Não envie pelo mesmo canal do arquivo.';

  @override
  String get passphraseTooShort =>
      'A senha compartilhada deve ter pelo menos 12 caracteres.';

  @override
  String get importTitle => 'Abrir um arquivo .klt';

  @override
  String get importPassphraseHelper =>
      'Deixe vazio se foi enviado para o seu próprio cofre.';

  @override
  String get importGo => 'Abrir e adicionar ao cofre';

  @override
  String importAddedSigned(String name) {
    return '$name foi adicionado ao cofre (assinado).';
  }

  @override
  String importAddedUnsigned(String name) {
    return '$name foi adicionado ao cofre (sem assinatura).';
  }

  @override
  String get importWrongKey =>
      'Este arquivo não abre com esta senha nem com o seu cofre.';

  @override
  String get importNotKlt => 'Este não é um arquivo .klt.';

  @override
  String get importDamaged => 'O arquivo está danificado ou foi alterado.';

  @override
  String get settingsProtections => 'Suas proteções';

  @override
  String get protPin => 'Proteção por PIN';

  @override
  String get protScreenshots => 'Bloqueio de capturas de tela';

  @override
  String get protScreenshotsValue => 'Ativado, em todas as telas';

  @override
  String get protAutoLock => 'Bloqueio automático';

  @override
  String get protAutoLockValue => 'Ao sair do app';

  @override
  String get protNetwork => 'Conexão Tor';

  @override
  String get protNetworkValue =>
      'Não conectado: a etapa 1 nunca fica online. O Tor chega na etapa 2.';

  @override
  String get torOff => 'Desligado: o Kilit não fica online.';

  @override
  String torStarting(int progress) {
    return 'Conectando… $progress%';
  }

  @override
  String get torReady => 'Conectado pelo Tor.';

  @override
  String get torFailed => 'Não foi possível conectar ao Tor.';

  @override
  String get torUnavailable => 'Ainda não disponível neste dispositivo.';

  @override
  String get torSwitch => 'Conectar pelo Tor';

  @override
  String get torSwitchHint =>
      'O Kilit só acessa a rede pelo Tor. Desligado, fica offline.';

  @override
  String get hwStrongbox => 'Chip de segurança StrongBox';

  @override
  String get hwTee => 'Ambiente de execução confiável (TEE)';

  @override
  String get hwTpm => 'TPM 2.0';

  @override
  String get hwOsSoftware => 'Android Keystore (sem hardware seguro)';

  @override
  String get hwSoftwareFile => 'Chave de software (ao lado do cofre)';

  @override
  String get hwNone => 'Nenhum';

  @override
  String get hwDev => 'Nenhum (núcleo de desenvolvimento)';

  @override
  String get hwBoundHint =>
      'Seu PIN está vinculado à chave de hardware deste aparelho. Nem uma cópia do arquivo do cofre pode ser testada em outro aparelho.';

  @override
  String get hwNotBoundHint =>
      'Sem chave de hardware: se o arquivo do cofre for copiado, o PIN pode ser adivinhado em outro aparelho.';

  @override
  String get settingsFingerprint => 'Seu número de assinatura do cofre';

  @override
  String get settingsFingerprintHint =>
      'Este número pertence às chaves do seu cofre, que assinam os pacotes que você sela (modo portador). Quem recebe de você um pacote assinado vê nele o número de quem assinou; se for igual a este, o que pode conferir com você pessoalmente ou numa ligação, o pacote é seu. Para conversas, compare o número de segurança dentro de cada conversa.';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get clipboardCheck =>
      'Oferecer a mensagem do Kilit da área de transferência';

  @override
  String get clipboardCheckHint =>
      'Quando o cofre abre, oferece abrir uma mensagem KLT1: da área de transferência. O Android mostra um aviso de que a área de transferência foi lida.';

  @override
  String get settingsPermissions => 'Permissões';

  @override
  String get permIntro => 'O Kilit só pede o que precisa, e só quando precisa.';

  @override
  String get permCamera => 'Câmera';

  @override
  String get permCameraValue =>
      'Para fotos nos chats. Pedido ao abrir a câmera pela primeira vez; nada vai para a galeria.';

  @override
  String get permNotifications => 'Notificações';

  @override
  String get permNotificationsValue =>
      'Não usado: nada das suas mensagens aparece fora do app.';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue =>
      'Só para o Tor embutido. Toda conexão passa por ele.';

  @override
  String get permOpenSystem => 'Abrir as permissões do sistema';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutLicense => 'Licença';

  @override
  String get aboutAlpha =>
      'Sem auditoria independente. Alfa: bom para testes, não para uso de alto risco.';

  @override
  String get settingsBridges => 'Conexão ao Tor';

  @override
  String get torRouteAuto => 'Automática';

  @override
  String get torRouteAutoHint =>
      'Direto ao Tor; por pontes se estiver bloqueado.';

  @override
  String get torRouteDirect => 'Direto ao Tor';

  @override
  String get torRouteObfs4 => 'Pontes obfs4';

  @override
  String get torRouteObfs4Hint => 'Para redes que bloqueiam o Tor.';

  @override
  String get torRouteSnowflake => 'Snowflake';

  @override
  String get torRouteSnowflakeHint => 'Para censura forte. Mais lento.';

  @override
  String get torRouteCustom => 'Minhas pontes';

  @override
  String get torRouteCustomHint =>
      'Linhas de ponte de bridges.torproject.org ou de alguém de confiança.';

  @override
  String get torRouteLinesHint => 'Uma linha de ponte por linha';

  @override
  String get resend => 'Enviar de novo';

  @override
  String get resendHint =>
      'Um relay tem esta mensagem, mas o dispositivo da pessoa ainda não confirmou que ela chegou. O Kilit a reenvia uma vez por dia durante uma semana, até chegar.';

  @override
  String get resendDone => 'Enviada de novo.';

  @override
  String get newGroup => 'Novo grupo';

  @override
  String get groupName => 'Nome do grupo';

  @override
  String groupPick(int count) {
    return 'Escolha até $count pessoas';
  }

  @override
  String get groupCreate => 'Criar';

  @override
  String groupMembers(int count) {
    return '$count pessoas';
  }

  @override
  String get groupInfo => 'Info do grupo';

  @override
  String get groupAdmin => 'admin';

  @override
  String get groupYou => 'Você';

  @override
  String get groupAddPeople => 'Adicionar pessoas';

  @override
  String get groupRemove => 'Remover do grupo';

  @override
  String get groupRename => 'Renomear grupo';

  @override
  String get groupEnd => 'Encerrar grupo';

  @override
  String get groupEndConfirm =>
      'Encerrar o grupo para todos? Ninguém poderá escrever nele depois.';

  @override
  String get groupLeave => 'Sair do grupo';

  @override
  String get groupLeaveConfirm =>
      'Sair deste grupo? As mensagens dele deixam de chegar a você.';

  @override
  String get groupDelete => 'Apagar grupo';

  @override
  String get groupEnded => 'Este grupo foi encerrado.';

  @override
  String get groupGone => 'Você não está mais neste grupo.';

  @override
  String groupDeliveredTo(int n, int total) {
    return 'Entregue a $n de $total';
  }

  @override
  String get groupNoContacts =>
      'Adicione contatos primeiro: um grupo é formado por pessoas que você adicionou.';

  @override
  String groupFull(int max) {
    return 'Um grupo tem no máximo $max pessoas.';
  }

  @override
  String groupNoticeCreated(String who) {
    return 'Criou o grupo: $who';
  }

  @override
  String groupNoticeJoined(String who) {
    return '$who adicionou você';
  }

  @override
  String groupNoticeAdded(String who, String whom) {
    return 'Adicionado: $whom · por: $who';
  }

  @override
  String groupNoticeRemoved(String who, String whom) {
    return 'Removido: $whom · por: $who';
  }

  @override
  String groupNoticeLeft(String who) {
    return 'Saiu: $who';
  }

  @override
  String groupNoticeRenamed(String who, String name) {
    return 'Novo nome do grupo “$name” · $who';
  }

  @override
  String groupNoticeEnded(String who) {
    return 'Encerrou o grupo: $who';
  }

  @override
  String groupNoticeRemovedYou(String who) {
    return '$who removeu você';
  }

  @override
  String get emojiButton => 'Emoji e figurinhas';

  @override
  String get stickers => 'Figurinhas';

  @override
  String get stickerLine => 'Figurinha';

  @override
  String get devicesTitle => 'Dispositivos vinculados';

  @override
  String get devicesIntro =>
      'Sua ID Kilit pode estar em até 5 dispositivos: seu telefone e os computadores que você vincular. Cada um tem suas próprias chaves e as mensagens chegam a todos.';

  @override
  String get deviceThis => 'Este dispositivo';

  @override
  String get devicePhone => 'Telefone';

  @override
  String deviceNumber(int n) {
    return 'Dispositivo $n';
  }

  @override
  String get deviceLink => 'Vincular um computador';

  @override
  String get deviceRemove => 'Remover';

  @override
  String get deviceRemoveConfirm =>
      'Remover este dispositivo? Ele deixa de receber suas mensagens. Se foi perdido, renove também sua ID Kilit.';

  @override
  String get linkToPhone => 'Vincular ao meu telefone';

  @override
  String get linkToPhoneHint =>
      'Torne este um dispositivo da ID Kilit do seu telefone. No telefone: Ajustes, Dispositivos vinculados, Vincular um computador. Depois leia este código.';

  @override
  String get linkOnlyNew =>
      'Só um Kilit novo, sem contatos, pode ser vinculado a um telefone.';

  @override
  String get linkWaiting =>
      'Aguardando o outro dispositivo. Os dois precisam do Tor.';

  @override
  String get linkCompare => 'Confira se a outra tela mostra o mesmo código:';

  @override
  String get linkDone =>
      'Vinculado. As mensagens agora chegam aos dois dispositivos.';

  @override
  String get linkNotCode => 'Isto não é um código de vinculação do Kilit.';

  @override
  String get linkedToPhone =>
      'Este dispositivo está vinculado à ID Kilit do seu telefone.';

  @override
  String get torChipFailed => 'Erro do Tor';

  @override
  String get protScreenshotsOffHint =>
      'Desligado: capturas e gravações de tela do Kilit funcionam, e ele aparece nos apps recentes.';

  @override
  String get torReconnect => 'Reconectar o Tor';

  @override
  String get torReconnectHint => 'Circuitos novos, e o Tor sai de novo';

  @override
  String get torReconnecting => 'Reconectando o Tor…';

  @override
  String get torRestartApp => 'Reiniciar o Kilit';

  @override
  String get torRestartHint =>
      'O Tor parou dentro do Kilit. Só reiniciar o traz de volta; você vai desbloquear de novo.';

  @override
  String get torDetailsTitle => 'Conexão Tor';

  @override
  String get torAnonTitle => 'Seu endereço IP está oculto';

  @override
  String get torAnonBody =>
      'O Kilit só sai para a rede pelo Tor. Ninguém vê seu endereço IP, e só quem conhece seu ID do Kilit pode falar com você.';

  @override
  String get torRouteTitle => 'O caminho das suas mensagens';

  @override
  String get torRouteYou => 'Você';

  @override
  String get torRouteYouHint => 'Seu endereço IP fica aqui';

  @override
  String get torHopGuard => 'Guarda: vê seu IP, não o que você envia';

  @override
  String get torHopMiddle => 'Relay do meio: não vê nenhum dos dois';

  @override
  String get torHopExit => 'Saída: vê o relay do Kilit, nunca você';

  @override
  String get torHopUnknown => 'um relay do Tor';

  @override
  String get torRouteRelays => 'Relays do Kilit';

  @override
  String get torRouteRelaysHint =>
      'Guardam as mensagens seladas até seu contato buscá-las; veem o Tor, não você';

  @override
  String get torRouteLayers => 'três camadas de criptografia';

  @override
  String get torNotReadyDiagram =>
      'Os relays que o Tor usa aparecem quando ele está pronto.';

  @override
  String get torLog => 'Registro do Tor';

  @override
  String get torLogEmpty => 'Nada registrado ainda.';

  @override
  String get torLogRefresh => 'Atualizar';

  @override
  String get torLogCopied => 'Registro do Tor copiado';

  @override
  String get torBlockedTitle => 'O Tor pode estar bloqueado aqui';

  @override
  String get torBlockedBody =>
      'O Kilit não alcançou a rede Tor. Uma ponte esconde que você usa o Tor. Escolha um jeito:';

  @override
  String get torBlockedOwn => 'Colar minhas próprias pontes';

  @override
  String get torBlockedOwnHint =>
      'Pegue em bridges.torproject.org ou por e-mail de bridges@torproject.org.';

  @override
  String get torBlockedLater => 'Agora não';

  @override
  String get selfNotes => 'Notas para mim';

  @override
  String get selfNotesHint => 'Criptografadas no cofre, só neste aparelho';

  @override
  String selfNotesCount(int count) {
    return 'Notas: $count';
  }

  @override
  String get selfNoteNew => 'Nova nota';

  @override
  String get selfNotesEmpty =>
      'Ainda não há notas. O que você escreve aqui é selado no cofre e só pode ser lido depois de desbloquear.';

  @override
  String get selfNoteDelete => 'Excluir nota';

  @override
  String get selfNoteDeleteConfirm =>
      'Excluir esta nota? Não dá para recuperá-la.';

  @override
  String get selfNoteSaved => 'Nota selada';

  @override
  String get selfNoteUnsaved => 'Sair sem salvar as alterações?';

  @override
  String get selfNoteDiscard => 'Descartar';

  @override
  String get linkTorWait =>
      'O Tor ainda não está conectado, então a vinculação espera. Os dois aparelhos precisam do Tor.';

  @override
  String linkFailed(String error) {
    return 'A vinculação não começou: $error';
  }

  @override
  String get linkScanInDevices =>
      'Este é um código para vincular um computador. No celular abra Ajustes, Dispositivos vinculados, Vincular um computador, e escaneie lá.';

  @override
  String get crashTitle => 'O Kilit fechou inesperadamente';

  @override
  String get crashBody =>
      'Da última vez o Kilit fechou sozinho. O relatório abaixo não contém mensagens nem chaves, só onde falhou. Copie e envie ao desenvolvedor, por exemplo numa issue do GitHub.';

  @override
  String get crashCopy => 'Copiar relatório';

  @override
  String get linkFetchingKey => 'Buscando a chave do computador nos relays…';

  @override
  String get deviceLinkById => 'Vincular um computador pelo ID do Kilit';

  @override
  String get linkById => 'Com ID do Kilit';

  @override
  String get linkByQr => 'Com código QR';

  @override
  String get linkIdField => 'O ID do Kilit do seu celular';

  @override
  String get linkIdHelp =>
      'Digite o ID do Kilit do seu celular. No celular abra Configurações, Aparelhos vinculados, Vincular um computador pelo ID do Kilit: ele mostra o ID e espera este computador.';

  @override
  String get linkIdSend => 'Enviar pedido';

  @override
  String get linkIdSent =>
      'Pedido enviado. No celular, aprove o pedido que mostra este código:';

  @override
  String get linkIdOrScan =>
      'Ou escaneie este código com o celular, na mesma tela:';

  @override
  String get linkListenHelp =>
      'No computador escolha Vincular ao meu celular, Com ID do Kilit, e digite este ID:';

  @override
  String get linkListenWaiting => 'Esperando o pedido do computador…';

  @override
  String get linkListenScan => 'Ou escanear o código do computador';

  @override
  String get linkRequestCode =>
      'Um computador pede para vincular. É este o código na tela dele?';

  @override
  String get linkRequestApprove => 'Mesmo código: vincular';

  @override
  String get linkRequestOther =>
      'Código diferente? Não aprove: outra pessoa enviou esse pedido.';

  @override
  String get deviceLeave => 'Sair deste ID do Kilit';

  @override
  String get deviceLeaveConfirm =>
      'Este computador sai do ID do Kilit do seu celular. As conversas, os contatos e os grupos deste computador são apagados; o celular mantém todos. Seus arquivos e notas do cofre ficam aqui. Você pode vincular este computador de novo mais tarde.';

  @override
  String get deviceLeaveDone =>
      'Este computador saiu do ID do Kilit. Agora é um novo Kilit.';

  @override
  String get deviceLeftTitle => 'Removido do ID do Kilit do seu celular';

  @override
  String get deviceLeft =>
      'Seu celular removeu este computador do ID do Kilit dele. As conversas, os contatos e os grupos deste computador foram apagados; seus arquivos e notas do cofre continuam. Para usá-lo de novo, vincule-o em Ajustes, Dispositivos vinculados.';

  @override
  String get cameraOpenSettings => 'Abrir ajustes da câmera';

  @override
  String get cameraIntroDesktop =>
      'No Windows a câmera entrega cada foto como um arquivo: o Kilit o lê na memória na hora, sobrescreve o arquivo e o apaga. As fotos não levam localização nem dados da câmera.';

  @override
  String get voiceRecord => 'Gravar mensagem de voz';

  @override
  String get voiceRecording => 'Gravando…';

  @override
  String get voiceStopped => 'Gravação parada';

  @override
  String get voiceLimitHint =>
      'O som fica na memória e é enviado criptografado. Uma mensagem de voz para em 5 minutos.';

  @override
  String get voiceNoMic =>
      'Não foi possível abrir o microfone. Permita que o Kilit use o microfone nas configurações do dispositivo.';

  @override
  String get voiceOpenSettings => 'Abrir ajustes do microfone';

  @override
  String get voiceMessage => 'Mensagem de voz';

  @override
  String get voicePlay => 'Reproduzir';

  @override
  String get voicePause => 'Pausar';

  @override
  String get voiceCannotPlay => 'Não é possível reproduzir';
}
