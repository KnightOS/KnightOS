#include <display.h>
//#include <text.h>
//#include <keyboard.h>
//#include <process.h>

//void launch_castle() {
//	launch_program("/bin/castle");
//	suspend();
//}
//
//void launch_threadlist() {
//	launch_program("/bin/threadlist");
//	suspend();
//}

void main(void) {
	SCREEN *screen = create_screen();
	*screen = 0xFF;
	//print_string(screen, "Hello, world!");
	fast_copy(screen);
	//KEY key;
	//do {
	//	key = get_key();
	//	if (key == KEY_F1) {
	//		launch_castle();
	//	}
	//	if (key == KEY_F5) {
	//		launch_threadlist();
	//	}
	//} while (key != KEY_MODE);
	while (1);
}
