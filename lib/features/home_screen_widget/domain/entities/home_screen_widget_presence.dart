// Se o usuário já colocou o widget do app na tela inicial.
// No Android o app pode pedir ao launcher que fixe o widget (pinRequested). O
// iOS, e launchers sem esse recurso, não deixam o app adicionar o widget
// sozinho; nesse caso (notAdded) a UI precisa ensinar o caminho pela galeria.
enum HomeScreenWidgetPresence { onHomeScreen, pinRequested, notAdded }
