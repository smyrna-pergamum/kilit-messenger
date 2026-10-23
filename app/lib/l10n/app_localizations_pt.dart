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
  String get chatsLater => 'Mensagens via Tor chegam na etapa 2.';

  @override
  String get cameraLater =>
      'Uma câmera que nunca grava texto puro no disco chega na etapa 2.';

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
  String get settingsFingerprint => 'Seu número de segurança';

  @override
  String get settingsFingerprintHint =>
      'Ao verificar um contato, ele deve ser igual nos dois aparelhos.';

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
  String get permIntro =>
      'No momento, o Kilit não usa nenhuma permissão sensível.';

  @override
  String get permCamera => 'Câmera';

  @override
  String get permCameraValue => 'Não usada (a câmera chega na etapa 2)';

  @override
  String get permNotifications => 'Notificações';

  @override
  String get permNotificationsValue => 'Não usadas';

  @override
  String get permInternet => 'Internet';

  @override
  String get permInternetValue => 'Nenhuma: a etapa 1 funciona offline';

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
}
