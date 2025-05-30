import 'package:opt_app/library/opt_app.dart';

class OcularHealthSelect extends StatefulWidget {
  final List<String> complaints;
  final EyeForComplaint location;
  final String patientName;
  final String patientPhone;
  final String patientEmail;

  const OcularHealthSelect({
    super.key,
    required this.complaints,
    required this.location,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
  });

  @override
  State<OcularHealthSelect> createState() => _OcularHealthSelectState();
}

class _OcularHealthSelectState extends State<OcularHealthSelect> {
  List<String> selectedOcularHealth = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppbar(
        hasLeading: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: PrimaryButton(
          text: "Next",
          isEnabled: selectedOcularHealth.isNotEmpty,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicalHealthSelect(
                  complaints: widget.complaints,
                  location: widget.location,
                  ocularHealth: selectedOcularHealth,
                  patientName: widget.patientName, // Pass patient details
                  patientPhone: widget.patientPhone,
                  patientEmail: widget.patientEmail,
                ),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select any ocular health \ncomplications that apply 👀",
                style: AppTypography().xxlBold,
                maxLines: 2,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "Select any ocular health complications that apply to this patient. This will help us better understand your ocular health history.",
                style: AppTypography().baseMedium,
                maxLines: 3,
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView(
                    shrinkWrap: true,
                    clipBehavior: Clip.none,
                    children: RemoteConfigRepository.ocularHealthList
                        .map((e) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (e.value == "none" &&
                                      selectedOcularHealth.contains(e.value)) {
                                    selectedOcularHealth.clear();
                                    selectedOcularHealth.remove(e.value!);
                                  } else if (e.value == "none" &&
                                      !selectedOcularHealth.contains(e.value)) {
                                    selectedOcularHealth.clear();
                                    selectedOcularHealth.add(e.value!);
                                  } else if (e.value != "none" &&
                                      selectedOcularHealth.contains(e.value)) {
                                    selectedOcularHealth.remove(e.value);
                                  } else {
                                    selectedOcularHealth.add(e.value!);
                                    selectedOcularHealth.remove("none");
                                  }
                                });
                              },
                              child: SelectTab(
                                complaint: e,
                                isSelected:
                                    selectedOcularHealth.contains(e.value),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
